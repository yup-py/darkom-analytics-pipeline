-- 1. Truncate the main ingestion table
TRUNCATE TABLE staging.raw_annonces RESTART IDENTITY CASCADE;

-- 2. Drop intermediate ETL helper tables completely
DROP TABLE IF EXISTS staging.clean_step1_standardized CASCADE;
DROP TABLE IF EXISTS staging.clean_step2_outliers CASCADE;
DROP TABLE IF EXISTS staging.clean_step3_imputed CASCADE;
DROP TABLE IF EXISTS staging.clean_step4_typed CASCADE;