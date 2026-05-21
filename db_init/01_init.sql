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

-- 3. Create Clean Production Data Structure Base
CREATE TABLE IF NOT EXISTS clean.annonces (
    annonce_id VARCHAR(50) PRIMARY KEY,
    date_publication DATE,
    ville VARCHAR(100),
    quartier VARCHAR(150),
    type_bien VARCHAR(100),
    transaction VARCHAR(50),
    prix NUMERIC,
    surface NUMERIC,
    nb_chambres INT,
    nb_salles_bain INT,
    etage INT,
    annee_construction INT,
    price_per_m2 NUMERIC,
    age_bien INT,
    categorie_prix VARCHAR(50),
    categorie_surface VARCHAR(50)
);