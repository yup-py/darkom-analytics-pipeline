-- Clear out previous runs to guarantee a clean, isolated environment
DROP TABLE IF EXISTS staging.clean_step1_standardized CASCADE;

CREATE TABLE staging.clean_step1_standardized AS 
SELECT 
    TRIM(annonce_id) AS annonce_id,
    TRIM(titre) AS titre, -- ◄ ADDED THIS LINE TO CAPTURE THE TITLE
    
    -- Extract only the YYYY-MM-DD portion from raw timestamps
    LEFT(TRIM(date_publication), 10) AS date_publication_raw,
    
    -- Text Standardization: Capitalize ONLY the first letter of each word
    INITCAP(TRIM(ville)) AS ville,
    INITCAP(TRIM(type_bien)) AS type_bien,
    
    -- Preserve empty neighborhoods as clear NULL markers for next steps
    CASE WHEN TRIM(quartier) = '' THEN NULL ELSE INITCAP(TRIM(quartier)) END AS quartier,
    
    -- Clean casing of explicit types; set raw empty spaces to NULL
    CASE 
        WHEN LOWER(TRIM(transaction)) = 'location' THEN 'Location'
        WHEN LOWER(TRIM(transaction)) = 'vente' THEN 'Vente'
        ELSE NULL 
    END AS transaction,
    
    -- SAFE METHOD: Pull the columns exactly as they are without stripping characters
    TRIM(prix) AS prix_raw,
    TRIM(surface) AS surface_raw,
    TRIM(nb_chambres) AS nb_chambres_raw,
    TRIM(nb_salles_bain) AS nb_salles_bain_raw,
    TRIM(etage) AS etage_raw,
    TRIM(annee_construction) AS annee_construction_raw

FROM staging.raw_annonces
-- Core System Filter: Exclude rows missing unique identifiers
WHERE annonce_id IS NOT NULL AND TRIM(annonce_id) != '';