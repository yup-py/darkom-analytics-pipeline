-- Clear out previous runs to guarantee a clean execution layer
DROP TABLE IF EXISTS staging.clean_step2_outliers CASCADE;

CREATE TABLE staging.clean_step2_outliers AS 
SELECT 
    annonce_id,
    titre, -- ◄ ADDED THIS LINE TO PASS IT TO STEP 3
    date_publication_raw,
    ville,
    quartier,
    type_bien,
    transaction,
    prix_raw,
    surface_raw,

    -- 1. Rooms Logic: Filters true typos, lets valid profiles pass through
    CASE 
        WHEN type_bien = 'terrain' THEN NULL
        WHEN nb_chambres_raw = '' OR nb_chambres_raw IS NULL THEN NULL
        WHEN type_bien = 'villa' AND CAST(nb_chambres_raw AS NUMERIC)::INT > 15 THEN NULL
        WHEN type_bien IN ('appartement', 'bureau', 'duplex') AND CAST(nb_chambres_raw AS NUMERIC)::INT > 8 THEN NULL
        ELSE CAST(nb_chambres_raw AS NUMERIC)::INT 
    END AS nb_chambres,

    -- 2. Bathrooms Logic
    CASE 
        WHEN type_bien = 'terrain' THEN NULL
        WHEN nb_salles_bain_raw = '' OR nb_salles_bain_raw IS NULL THEN NULL
        WHEN type_bien = 'villa' AND CAST(nb_salles_bain_raw AS NUMERIC)::INT > 10 THEN NULL
        WHEN type_bien IN ('appartement', 'bureau', 'duplex') AND CAST(nb_salles_bain_raw AS NUMERIC)::INT > 5 THEN NULL
        ELSE CAST(nb_salles_bain_raw AS NUMERIC)::INT 
    END AS nb_salles_bain,

    -- 3. UPDATED Floor Logic: Villa and Terrain are strictly set to 0 (Ground level)
    CASE 
        WHEN type_bien IN ('terrain', 'villa') THEN 0
        WHEN etage_raw = '' OR etage_raw IS NULL THEN NULL
        WHEN type_bien IN ('appartement', 'bureau', 'duplex') AND CAST(etage_raw AS NUMERIC)::INT > 25 THEN NULL
        ELSE CAST(etage_raw AS NUMERIC)::INT 
    END AS etage,

    -- 4. Construction Year Logic
    CASE 
        WHEN type_bien = 'terrain' THEN NULL
        WHEN annee_construction_raw = '' OR annee_construction_raw IS NULL THEN NULL
        WHEN CAST(annee_construction_raw AS NUMERIC)::INT NOT BETWEEN 1950 AND 2026 THEN NULL
        ELSE CAST(annee_construction_raw AS NUMERIC)::INT 
    END AS annee_construction

FROM staging.clean_step1_standardized
-- Drop rows containing impossible core values for the Moroccan real estate market
WHERE 
    prix_raw != '' AND prix_raw IS NOT NULL AND CAST(prix_raw AS NUMERIC) > 0
    AND surface_raw != '' AND surface_raw IS NOT NULL AND CAST(surface_raw AS NUMERIC) > 0
    AND (
        (transaction = 'Location' AND CAST(prix_raw AS NUMERIC) BETWEEN 400 AND 60000) OR
        (transaction = 'Vente' AND CAST(prix_raw AS NUMERIC) BETWEEN 80000 AND 15000000) OR
        (transaction IS NULL) 
    );