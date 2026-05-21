-- 1. BI_SCHEMA: STAR SCHEMA (FACTS & DIMENSIONS)

CREATE TABLE IF NOT EXISTS bi_schema.dim_localisation (
    loc_id SERIAL PRIMARY KEY,
    ville TEXT,
    quartier TEXT,
    UNIQUE (ville, quartier)
);

CREATE TABLE IF NOT EXISTS bi_schema.dim_temps (
    date_key INTEGER PRIMARY KEY,
    full_date DATE,
    annee INT,
    mois INT,
    nom_mois TEXT,
    trimestre INT
);

CREATE TABLE IF NOT EXISTS bi_schema.dim_caracteristiques (
    carac_id SERIAL PRIMARY KEY,
    type_bien TEXT,
    transaction TEXT,
    categorie_prix TEXT,
    categorie_surface TEXT,
    UNIQUE (type_bien, transaction, categorie_prix, categorie_surface)
);

CREATE TABLE IF NOT EXISTS bi_schema.fact_annonces (
    annonce_id TEXT PRIMARY KEY,
    date_key INTEGER REFERENCES bi_schema.dim_temps(date_key),
    loc_id INTEGER REFERENCES bi_schema.dim_localisation(loc_id),
    carac_id INTEGER REFERENCES bi_schema.dim_caracteristiques(carac_id),
    prix NUMERIC,
    surface NUMERIC,
    prix_m2 NUMERIC,
    nb_chambres INT,
    nb_salles_bain INT,
    etage INT,
    age_bien INT
);

-- Indexing Key Structural Connection Elements for Faster Join Actions inside Power BI
CREATE INDEX IF NOT EXISTS idx_fact_loc ON bi_schema.fact_annonces(loc_id);
CREATE INDEX IF NOT EXISTS idx_fact_date ON bi_schema.fact_annonces(date_key);
CREATE INDEX IF NOT EXISTS idx_fact_carac ON bi_schema.fact_annonces(carac_id);

-- Load Dimension Data
INSERT INTO bi_schema.dim_localisation (ville, quartier)
SELECT DISTINCT ville, quartier FROM clean.annonces
ON CONFLICT DO NOTHING;

INSERT INTO bi_schema.dim_temps (date_key, full_date, annee, mois, nom_mois, trimestre)
SELECT DISTINCT 
    TO_CHAR(date_publication, 'YYYYMMDD')::INTEGER,
    date_publication,
    EXTRACT(YEAR FROM date_publication)::INT,
    EXTRACT(MONTH FROM date_publication)::INT,
    TO_CHAR(date_publication, 'TMMonth'),
    EXTRACT(QUARTER FROM date_publication)::INT
FROM clean.annonces
ON CONFLICT DO NOTHING;

INSERT INTO bi_schema.dim_caracteristiques (type_bien, transaction, categorie_prix, categorie_surface)
SELECT DISTINCT type_bien, transaction, categorie_prix, categorie_surface FROM clean.annonces
ON CONFLICT DO NOTHING;

-- Populate Analytical Fact Table
TRUNCATE bi_schema.fact_annonces CASCADE;
INSERT INTO bi_schema.fact_annonces (annonce_id, date_key, loc_id, carac_id, prix, surface, prix_m2, nb_chambres, nb_salles_bain, etage, age_bien)
SELECT 
    a.annonce_id,
    TO_CHAR(a.date_publication, 'YYYYMMDD')::INTEGER,
    l.loc_id,
    c.carac_id,
    a.prix, 
    a.surface,
    a.price_per_m2,
    a.nb_chambres,
    a.nb_salles_bain,
    a.etage,
    a.age_bien
FROM clean.annonces a
JOIN bi_schema.dim_localisation l ON a.ville = l.ville AND a.quartier = l.quartier
JOIN bi_schema.dim_caracteristiques c ON a.type_bien = c.type_bien AND a.transaction = c.transaction 
    AND a.categorie_prix = c.categorie_prix AND a.categorie_surface = c.categorie_surface;


-- 2. ML_SCHEMA: ONE BIG TABLE (OBT) FOR ML MODELING

CREATE TABLE IF NOT EXISTS ml_schema.obt_annonces (
    annonce_id TEXT PRIMARY KEY,
    type_bien TEXT,
    transaction TEXT,
    ville TEXT,
    quartier TEXT,
    surface NUMERIC,
    nb_chambres INT,
    nb_salles_bain INT,
    etage INT,
    age_bien INT,
    prix NUMERIC
);

TRUNCATE ml_schema.obt_annonces;
INSERT INTO ml_schema.obt_annonces
SELECT annonce_id, type_bien, transaction, ville, quartier, surface, nb_chambres, nb_salles_bain, etage, age_bien, prix
FROM clean.annonces;