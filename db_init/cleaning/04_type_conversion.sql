-- Convert staging text data into clean operational data types safely

DROP TABLE IF EXISTS staging.clean_step4_typed CASCADE;

CREATE TABLE staging.clean_step4_typed AS 
SELECT 
    annonce_id,
    
    date_publication_raw AS date_publication,
    
    ville,
    quartier,
    type_bien,
    transaction,
    
    -- Cast metrics to standard numeric calculations
    CAST(prix_raw AS NUMERIC) AS prix,
    CAST(surface_raw AS NUMERIC) AS surface,
    
    nb_chambres,
    nb_salles_bain,
    etage,
    annee_construction
FROM staging.clean_step3_imputed;

-- Verification count
SELECT 'Type Conversion Intermediary Complete' AS status, COUNT(*) FROM staging.clean_step4_typed;