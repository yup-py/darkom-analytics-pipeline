-- 04_purge_staging.sql
-- Final Step: Clean up all staging tables to free up database resources

TRUNCATE staging.raw_annonces CASCADE;
TRUNCATE staging.clean_step1_standardized CASCADE;
TRUNCATE staging.clean_step2_outliers CASCADE;
TRUNCATE staging.clean_step3_imputed CASCADE;
TRUNCATE staging.clean_step4_typed CASCADE;