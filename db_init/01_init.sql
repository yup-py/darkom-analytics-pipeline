-- 1. Create System Boundaries
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS clean;
CREATE SCHEMA IF NOT EXISTS bi_schema;
CREATE SCHEMA IF NOT EXISTS ml_schema;

-- 2. Create Raw Staging Interface (All Text Fields to Prevent Load Failures)
CREATE TABLE IF NOT EXISTS staging.raw_annonces (
    annonce_id TEXT,
    date_publication TEXT,
    titre TEXT,
    ville TEXT,
    quartier TEXT,
    type_bien TEXT,
    transaction TEXT,
    prix TEXT,
    surface TEXT,
    nb_chambres TEXT,
    nb_salles_bain TEXT,
    etage TEXT,
    annee_construction TEXT,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);