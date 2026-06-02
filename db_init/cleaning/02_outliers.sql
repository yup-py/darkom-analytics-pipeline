-- Clear out previous runs to guarantee a clean execution layer
DROP TABLE IF EXISTS staging.clean_step2_outliers CASCADE;

CREATE TABLE staging.clean_step2_outliers AS 
WITH base_clean AS (
    -- 1. Apply structural logical constraints and safely parse numeric targets
    SELECT 
        annonce_id,
        titre, 
        date_publication_raw,
        ville,
        quartier,
        type_bien,
        transaction,
        prix_raw,
        surface_raw,
        CAST(prix_raw AS NUMERIC) AS prix_num, 
        
        -- Safe surface parsing: Allow Terrains to pass NULL surfaces
        CASE 
            WHEN surface_raw = '' OR surface_raw IS NULL THEN NULL 
            ELSE CAST(surface_raw AS NUMERIC) 
        END AS surface_num,

        -- Rooms Logic: Case-insensitive checks
        CASE 
            WHEN LOWER(type_bien) = 'terrain' THEN NULL
            WHEN nb_chambres_raw = '' OR nb_chambres_raw IS NULL THEN NULL
            WHEN LOWER(type_bien) = 'villa' AND CAST(nb_chambres_raw AS NUMERIC)::INT > 15 THEN NULL
            WHEN LOWER(type_bien) IN ('appartement', 'bureau', 'duplex') AND CAST(nb_chambres_raw AS NUMERIC)::INT > 8 THEN NULL
            ELSE CAST(nb_chambres_raw AS NUMERIC)::INT 
        END AS nb_chambres,

        -- Bathrooms Logic: Case-insensitive checks
        CASE 
            WHEN LOWER(type_bien) = 'terrain' THEN NULL
            WHEN nb_salles_bain_raw = '' OR nb_salles_bain_raw IS NULL THEN NULL
            WHEN LOWER(type_bien) = 'villa' AND CAST(nb_salles_bain_raw AS NUMERIC)::INT > 10 THEN NULL
            WHEN LOWER(type_bien) IN ('appartement', 'bureau', 'duplex') AND CAST(nb_salles_bain_raw AS NUMERIC)::INT > 5 THEN NULL
            ELSE CAST(nb_salles_bain_raw AS NUMERIC)::INT 
        END AS nb_salles_bain,

        -- Floor Logic: Case-insensitive checks
        CASE 
            WHEN LOWER(type_bien) IN ('terrain', 'villa') THEN 0
            WHEN etage_raw = '' OR etage_raw IS NULL THEN NULL
            WHEN LOWER(type_bien) IN ('appartement', 'bureau', 'duplex') AND CAST(etage_raw AS NUMERIC)::INT > 25 THEN NULL
            ELSE CAST(etage_raw AS NUMERIC)::INT 
        END AS etage,

        -- Construction Year Logic: Case-insensitive checks
        CASE 
            WHEN LOWER(type_bien) = 'terrain' THEN NULL
            WHEN annee_construction_raw = '' OR annee_construction_raw IS NULL THEN NULL
            WHEN CAST(annee_construction_raw AS NUMERIC)::INT NOT BETWEEN 1950 AND 2026 THEN NULL
            ELSE CAST(annee_construction_raw AS NUMERIC)::INT 
        END AS annee_construction

    FROM staging.clean_step1_standardized
    WHERE 
        prix_raw != '' AND prix_raw IS NOT NULL AND CAST(prix_raw AS NUMERIC) > 0
        AND (
            LOWER(type_bien) = 'terrain' 
            OR (surface_raw != '' AND surface_raw IS NOT NULL AND CAST(surface_raw AS NUMERIC) > 0)
        )
),
iqr_stats AS (
    -- 2. Calculate dynamic Q1 and Q3 parameters
    SELECT 
        ville,
        type_bien,
        transaction,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY prix_num) AS p_q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY prix_num) AS p_q3,
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY surface_num) AS s_q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY surface_num) AS s_q3
    FROM base_clean
    GROUP BY ville, type_bien, transaction
)
-- 3. Combine base records and apply conditional IQR + hard caps
SELECT 
    b.annonce_id,
    b.titre, 
    b.date_publication_raw,
    b.ville,
    b.quartier,
    b.type_bien,
    b.transaction,
    b.prix_raw,
    b.surface_raw,
    b.nb_chambres,
    b.nb_salles_bain,
    b.etage,
    b.annee_construction
FROM base_clean b
INNER JOIN iqr_stats s 
    ON b.ville = s.ville 
    AND b.type_bien = s.type_bien 
    AND b.transaction = s.transaction
WHERE 
    -- Standard IQR rules for baseline cleaning
    b.prix_num >= (s.p_q1 - 1.5 * (s.p_q3 - s.p_q1))
    AND b.prix_num <= (s.p_q3 + 1.5 * (s.p_q3 - s.p_q1))
    
    AND (
        LOWER(b.type_bien) = 'terrain'
        OR (
            b.surface_num >= (s.s_q1 - 1.5 * (s.s_q3 - s.s_q1))
            AND b.surface_num <= (s.s_q3 + 1.5 * (s.s_q3 - s.s_q1))
        )
    )

    -- Strict logical overrides to catch the specific leaks
    AND (
        LOWER(b.type_bien) != 'duplex'
        OR (b.prix_num <= 15000000 AND b.surface_num <= 700)
    );