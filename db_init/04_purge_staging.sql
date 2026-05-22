-- 1. Truncate the main ingestion table (Preserves structure/columns for the next run)
TRUNCATE TABLE staging.raw_annonces RESTART IDENTITY CASCADE;

-- 2. Drop intermediate ETL helper tables completely to free up disk space
DROP TABLE IF EXISTS staging.clean_step1_standardized CASCADE;
DROP TABLE IF EXISTS staging.clean_step2_outliers CASCADE;
DROP TABLE IF EXISTS staging.clean_step3_imputed CASCADE;
DROP TABLE IF EXISTS staging.clean_step4_typed CASCADE;