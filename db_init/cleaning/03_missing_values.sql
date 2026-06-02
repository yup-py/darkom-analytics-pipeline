-- 03_missing_values.sql

DROP TABLE IF EXISTS staging.clean_step3_imputed CASCADE;

CREATE TABLE staging.clean_step3_imputed AS 
WITH base_deduplicated AS (
    -- Deduplication and Date sanitization
    SELECT DISTINCT ON (annonce_id) 
        *, 
        ctid AS original_order,
        NULLIF(date_publication_raw, '')::DATE AS date_publication_sanitized
    FROM staging.clean_step2_outliers
),
extracted_type_bien AS (
    -- Extract missing property types dynamically from the listing title
    SELECT b.*,
        CASE 
            WHEN b.type_bien IS NOT NULL AND b.type_bien != '' THEN INITCAP(TRIM(b.type_bien))
            WHEN LOWER(r.titre) LIKE '%appartement%' THEN 'Appartement'
            WHEN LOWER(r.titre) LIKE '%villa%' THEN 'Villa'
            WHEN LOWER(r.titre) LIKE '%terrain%' THEN 'Terrain'
            WHEN LOWER(r.titre) LIKE '%bureau%' THEN 'Bureau'
            WHEN LOWER(r.titre) LIKE '%duplex%' THEN 'Duplex'
            ELSE 'Appartement'
        END AS clean_type_bien
    FROM base_deduplicated b
    LEFT JOIN staging.raw_annonces r ON b.annonce_id = r.annonce_id
),
date_ffill_groups AS (
    SELECT *,
        COUNT(date_publication_sanitized) OVER (ORDER BY original_order ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS date_group_ffill
    FROM extracted_type_bien
),
date_ffill_applied AS (
    SELECT *,
        FIRST_VALUE(date_publication_sanitized) OVER (PARTITION BY date_group_ffill ORDER BY original_order) AS date_ffilled
    FROM date_ffill_groups
),
date_bfill_groups AS (
    SELECT *,
        COUNT(date_ffilled) OVER (ORDER BY original_order DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS date_group_bfill
    FROM date_ffill_applied
),
date_bfill_applied AS (
    -- Apply Backward Fill to get the final clean_date
    SELECT *,
        FIRST_VALUE(date_ffilled) OVER (PARTITION BY date_group_bfill ORDER BY original_order DESC) AS final_date
    FROM date_bfill_groups
),
neighborhood_counts AS (
    -- Count occurrences of each neighborhood per city safely
    SELECT 
        ville,
        quartier,
        COUNT(*) as freq
    FROM base_deduplicated
    WHERE quartier IS NOT NULL AND quartier NOT IN ('', 'Non Spécifié')
    GROUP BY ville, quartier
),
neighborhood_modes AS (
    -- Robust calculation of Mode using window partitions
    SELECT 
        ville,
        quartier AS mode_quartier
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY ville ORDER BY freq DESC) as rn
        FROM neighborhood_counts
    ) sub
    WHERE rn = 1
),
structural_medians AS (
    -- Calculate structural medians grouped by Category and Surface Area buckets
    SELECT 
        clean_type_bien,
        WIDTH_BUCKET(CAST(surface_raw AS NUMERIC), 0, 2000, 40) as surf_bucket,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY nb_chambres) AS median_rooms,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY nb_salles_bain) AS median_baths,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY etage) AS median_etage
    FROM extracted_type_bien
    GROUP BY clean_type_bien, WIDTH_BUCKET(CAST(surface_raw AS NUMERIC), 0, 2000, 40)
),
year_medians AS (
    -- Calculate local construction year medians based on Quartier within Ville
    SELECT 
        ville,
        quartier,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY annee_construction) AS median_year
    FROM base_deduplicated
    WHERE annee_construction IS NOT NULL
    GROUP BY ville, quartier
)
SELECT 
    f.annonce_id,
    CAST(f.final_date AS DATE) AS date_publication_raw,
    f.ville,
    
    -- Impute Neighborhood based on the City's Mode, fallback to Centre Ville if the whole city is empty
    
    COALESCE(NULLIF(f.quartier, 'Non Spécifié'), nm.mode_quartier, 'Centre Ville') AS quartier,
    f.clean_type_bien AS type_bien,
    
    -- Custom Transaction Rule

    CASE 
        WHEN f.transaction IS NOT NULL THEN f.transaction
        WHEN CAST(f.prix_raw AS NUMERIC) < 50000 THEN 'Location'
        ELSE 'Vente'
    END AS transaction,
    
    f.prix_raw,
    f.surface_raw,
    
    -- Impute Rooms and Baths

    CASE 
        WHEN f.clean_type_bien = 'Terrain' THEN NULL
        ELSE COALESCE(f.nb_chambres, CEIL(sm.median_rooms)::INT, 2)
    END AS nb_chambres,
    
    CASE 
        WHEN f.clean_type_bien = 'Terrain' THEN NULL
        ELSE COALESCE(f.nb_salles_bain, CEIL(sm.median_baths)::INT, 1)
    END AS nb_salles_bain,
    
    -- Impute Floor

    CASE 
        WHEN f.clean_type_bien IN ('Terrain', 'Villa') THEN 0
        ELSE COALESCE(f.etage, CEIL(sm.median_etage)::INT, 1)
    END AS etage,
    
    -- Impute Construction Year
    
    CASE 
        WHEN f.clean_type_bien = 'Terrain' THEN NULL
        ELSE COALESCE(f.annee_construction, CEIL(ym.median_year)::INT, 2015)
    END AS annee_construction

FROM date_bfill_applied f
LEFT JOIN neighborhood_modes nm ON f.ville = nm.ville
LEFT JOIN structural_medians sm 
    ON f.clean_type_bien = sm.clean_type_bien 
    AND WIDTH_BUCKET(CAST(f.surface_raw AS NUMERIC), 0, 2000, 40) = sm.surf_bucket
LEFT JOIN year_medians ym 
    ON f.ville = ym.ville AND f.quartier = ym.quartier;