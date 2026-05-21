-- =========================================================================
-- DATA QUALITY AUDIT: MISSING VALUE DETECTION
-- Target Layer: clean.annonces (or staging.clean_step4_typed)
-- =========================================================================

-------------------------------------------------------------------------
-- PART 1: GLOBAL DATA QUALITY SUMMARY
-------------------------------------------------------------------------
SELECT 
    COUNT(*) AS total_records,
    
    -- Missing Dates
    SUM(CASE WHEN date_publication IS NULL THEN 1 ELSE 0 END) AS missing_dates_count,
    ROUND(100.0 * SUM(CASE WHEN date_publication IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) || '%' AS missing_dates_pct,
    
    -- Missing Neighborhoods
    SUM(CASE WHEN quartier IS NULL OR quartier = 'Non Spécifié' THEN 1 ELSE 0 END) AS missing_quartier_count,
    ROUND(100.0 * SUM(CASE WHEN quartier IS NULL OR quartier = 'Non Spécifié' THEN 1 ELSE 0 END) / COUNT(*), 2) || '%' AS missing_quartier_pct,
    
    -- Missing Prices
    SUM(CASE WHEN prix IS NULL OR prix = 0 THEN 1 ELSE 0 END) AS missing_prix_count,
    ROUND(100.0 * SUM(CASE WHEN prix IS NULL OR prix = 0 THEN 1 ELSE 0 END) / COUNT(*), 2) || '%' AS missing_prix_pct,
    
    -- Missing Surface Area
    SUM(CASE WHEN surface IS NULL OR surface = 0 THEN 1 ELSE 0 END) AS missing_surface_count,
    ROUND(100.0 * SUM(CASE WHEN surface IS NULL OR surface = 0 THEN 1 ELSE 0 END) / COUNT(*), 2) || '%' AS missing_surface_pct,
    
    -- Missing Structural Attributes (Excluding Terrains where NULL is expected)
    SUM(CASE WHEN type_bien != 'Terrain' AND (nb_chambres IS NULL OR nb_salles_bain IS NULL) THEN 1 ELSE 0 END) AS missing_structural_specs_count
FROM clean.annonces;


-------------------------------------------------------------------------
-- PART 2: ROW-LEVEL DRILL DOWN (EXACTLY WHERE AND WHAT IS MISSING)
-------------------------------------------------------------------------
SELECT 
    annonce_id,
    ville,
    type_bien,
    transaction,
    -- Build a dynamic flag string indicating exactly what is missing in this row
    CONCAT_WS(', ',
        CASE WHEN date_publication IS NULL THEN 'Missing Date' END,
        CASE WHEN quartier IS NULL OR quartier = 'Non Spécifié' THEN 'Missing Quartier' END,
        CASE WHEN prix IS NULL OR prix = 0 THEN 'Missing/Zero Prix' END,
        CASE WHEN surface IS NULL OR surface = 0 THEN 'Missing/Zero Surface' END,
        CASE WHEN type_bien != 'Terrain' AND nb_chambres IS NULL THEN 'Missing Rooms' END,
        CASE WHEN type_bien != 'Terrain' AND nb_salles_bain IS NULL THEN 'Missing Bathrooms' END
    ) AS missing_attributes_log
FROM clean.annonces
WHERE 
    date_publication IS NULL 
    OR quartier IS NULL 
    OR quartier = 'Non Spécifié'
    OR prix IS NULL 
    OR prix = 0
    OR surface IS NULL 
    OR surface = 0
    OR (type_bien != 'Terrain' AND (nb_chambres IS NULL OR nb_salles_bain IS NULL))
ORDER BY ville, type_bien;