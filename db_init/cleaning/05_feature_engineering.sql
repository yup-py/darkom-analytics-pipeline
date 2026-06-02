-- Perform mathematical feature engineering and load to production cleanly

BEGIN;

-- 1. Clear out any existing production data 
TRUNCATE TABLE clean.annonces CASCADE;

-- 2. Insert into production using DISTINCT ON to guarantee Primary Key uniqueness
INSERT INTO clean.annonces (
    annonce_id,
    date_publication,
    ville,
    quartier,
    type_bien,
    transaction,
    prix,
    surface,
    nb_chambres,
    nb_salles_bain,
    etage,
    annee_construction,
    price_per_m2,
    age_bien,
    categorie_prix,
    categorie_surface
)
SELECT DISTINCT ON (annonce_id)
    annonce_id,
    date_publication,
    ville,
    quartier,
    type_bien,
    transaction,
    prix,
    surface,
    nb_chambres,
    nb_salles_bain,
    etage,
    annee_construction,
    
    -- Feature 1: Price per Square Meter
    CASE 
        WHEN surface > 0 THEN ROUND(prix / surface, 2) 
        ELSE 0                                      
    END AS price_per_m2,
    
    -- Feature 2: Age of property (relative to current year 2026)
    CASE 
        WHEN annee_construction IS NOT NULL THEN (2026 - annee_construction)
        ELSE NULL 
    END AS age_bien,
    
    -- Feature 3: Market Pricing Segments
    CASE 
        WHEN transaction = 'Location' THEN
            CASE 
                WHEN prix < 3000 THEN 'Économique'
                WHEN prix BETWEEN 3000 AND 7999 THEN 'Moyen'
                WHEN prix BETWEEN 8000 AND 15000 THEN 'Haut standing'
                ELSE 'Luxe'
            END
        ELSE
            CASE 
                WHEN prix < 600000 THEN 'Économique'
                WHEN prix BETWEEN 600000 AND 1999999 THEN 'Moyen'
                WHEN prix BETWEEN 2000000 AND 5000000 THEN 'Haut standing'
                ELSE 'Luxe'
            END
    END AS categorie_prix,
    
    -- Feature 4: Surface Area Binning Segments
    CASE 
        WHEN surface < 80 THEN 'Petit (< 80 m²)'
        WHEN surface BETWEEN 80 AND 150 THEN 'Moyen (80-150 m²)'
        ELSE 'Grand (> 150 m²)'
    END AS categorie_surface
FROM staging.clean_step4_typed
ORDER BY annonce_id, date_publication DESC; -- Keeps the newest listing entry if duplicate IDs try to pass through

COMMIT;

-- Verify final successful production load count
SELECT 'Clean Production Table Loaded Successfully' AS status, COUNT(*) FROM clean.annonces;