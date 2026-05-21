-- 05_feature_engineering.sql
-- Step 5: Perform mathematical feature engineering and load to production cleanly

BEGIN;

-- 1. Clear out any existing production data to avoid duplicate key violations
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
SELECT DISTINCT ON (annonce_id) -- DEFENSIVE FIX: Permanently guarantees no duplicate primary keys can be inserted
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
    
    -- Feature 1: Price per Square Meter (Logical separation based on rental vs sale)
    -- For Vente: Standard absolute value (Price / Surface)
    -- For Location: Annualized yield per square meter ((Price * 12) / Surface) so charts look clean
    CASE 
        WHEN transaction = 'Location' THEN ROUND((prix * 12) / surface, 2) 
        ELSE ROUND(prix / surface, 2)                                      
    END AS price_per_m2,
    
    -- Feature 2: Age of property (relative to current year 2026)
    CASE 
        WHEN annee_construction IS NOT NULL THEN (2026 - annee_construction)
        ELSE NULL 
    END AS age_bien,
    
    -- Feature 3: Market Pricing Segments (Differentiated based on transaction logic)
    CASE 
        WHEN transaction = 'Location' THEN
            CASE 
                WHEN prix < 3000 THEN 'Économique'
                WHEN prix BETWEEN 3000 AND 8000 THEN 'Moyen standing'
                ELSE 'Haut standing'
            END
        ELSE -- Logic for 'Vente' (Sales)
            CASE 
                WHEN prix < 600000 THEN 'Économique'
                WHEN prix BETWEEN 600000 AND 2000000 THEN 'Moyen standing'
                ELSE 'Haut standing'
            END
    END AS categorie_prix,
    
    -- Feature 4: Surface Area Binning Segments
    CASE 
        WHEN surface < 60 THEN 'Petit (<60m²)'
        WHEN surface BETWEEN 60 AND 120 THEN 'Moyen (60-120m²)'
        WHEN surface BETWEEN 120 AND 250 THEN 'Grand (120-250m²)'
        ELSE 'Très Grand (>250m²)'
    END AS categorie_surface
FROM staging.clean_step4_typed
ORDER BY annonce_id, date_publication DESC; -- Keeps the newest listing entry if duplicate IDs try to pass through

COMMIT;

-- Verify final successful production load count
SELECT 'Clean Production Table Loaded Successfully' AS status, COUNT(*) FROM clean.annonces;