import os
import sys
import time
from utils.setup_db import initialize_database_and_tables
from utils.db_connect import get_db_connection
from utils.extract_load import load_csv_to_staging

print("=========================================================================")
print("🚀 STARTING PRODUCTION DARKOM PIPELINE ENGINE")
print("=========================================================================\n")

# -------------------------------------------------------------------------
# STEP 1: INITIALIZE DATABASE SCHEMAS
# -------------------------------------------------------------------------
print("⏳ [1/8] Verifying database infrastructure setup...")
try:
    initialize_database_and_tables()
    print("✅ Schema verification clear. Structures are ready.\n")
except Exception as e:
    print(f"❌ Structural initialization aborted: {e}")
    sys.exit(1)

# Establish connection bridge to clean database target context
conn = get_db_connection()
cursor = conn.cursor()
print("✅ Connected securely to PostgreSQL Database.\n")

try:
    # -------------------------------------------------------------------------
    # STEP 2: INGEST RAW DATA
    # -------------------------------------------------------------------------
    csv_file_path = os.path.join('data', 'raw', 'darkom_annonces.csv') 
    print("⏳ [2/8] Ingesting raw CSV records into Staging Layer...")
    start_time = time.time()
    load_csv_to_staging(conn, csv_file_path)
    conn.commit()
    print(f"✅ Raw data ingestion committed successfully ({time.time() - start_time:.2f}s).\n")

    print("-------------------------------------------------------------------------")
    print("📂 EXECUTING MODULAR DATA CLEANING SEQUENCE")
    print("-------------------------------------------------------------------------")

    # -------------------------------------------------------------------------
    # STEP 3: MODULAR CLEANING - 01_STANDARDIZE
    # -------------------------------------------------------------------------
    print("⏳ [3/8] Executing SQL Module: 01_standardize.sql...")
    start_time = time.time()
    with open(os.path.join('db_init', 'cleaning', '01_standardize.sql'), 'r', encoding='utf-8') as f:
        cursor.execute(f.read())
    conn.commit()
    print(f"✅ Step 1 complete ({time.time() - start_time:.2f}s).\n")

    # -------------------------------------------------------------------------
    # STEP 4: MODULAR CLEANING - 02_OUTLIERS (FIXED FILE NAME)
    # -------------------------------------------------------------------------
    print("⏳ [4/8] Executing SQL Module: 02_outliers.sql...")
    start_time = time.time()
    with open(os.path.join('db_init', 'cleaning', '02_outliers.sql'), 'r', encoding='utf-8') as f:
        cursor.execute(f.read())
    conn.commit()
    print(f"✅ Step 2 complete ({time.time() - start_time:.2f}s).\n")

    # -------------------------------------------------------------------------
    # STEP 5: MODULAR CLEANING - 03_MISSING_VALUES (FIXED FILE NAME)
    # -------------------------------------------------------------------------
    print("⏳ [5/8] Executing SQL Module: 03_missing_values.sql...")
    start_time = time.time()
    with open(os.path.join('db_init', 'cleaning', '03_missing_values.sql'), 'r', encoding='utf-8') as f:
        cursor.execute(f.read())
    conn.commit()
    print(f"✅ Step 3 complete ({time.time() - start_time:.2f}s).\n")

    # -------------------------------------------------------------------------
    # STEP 6: MODULAR CLEANING - 04_TYPE_CONVERSION (ADDED STEP)
    # -------------------------------------------------------------------------
    print("⏳ [6/8] Executing SQL Module: 04_type_conversion.sql...")
    start_time = time.time()
    with open(os.path.join('db_init', 'cleaning', '04_type_conversion.sql'), 'r', encoding='utf-8') as f:
        cursor.execute(f.read())
    conn.commit()
    print(f"✅ Step 4 complete ({time.time() - start_time:.2f}s).\n")

    # -------------------------------------------------------------------------
    # STEP 7: MODULAR CLEANING - 05_FEATURE_ENGINEERING (ADDED STEP)
    # -------------------------------------------------------------------------
    print("⏳ [7/8] Executing SQL Module: 05_feature_engineering.sql...")
    start_time = time.time()
    with open(os.path.join('db_init', 'cleaning', '05_feature_engineering.sql'), 'r', encoding='utf-8') as f:
        cursor.execute(f.read())
    conn.commit()
    print(f"✅ Step 5 complete ({time.time() - start_time:.2f}s).\n")

    print("-------------------------------------------------------------------------")
    print("⚙️ EXECUTING POST-PROCESSING PROCEDURES")
    print("-------------------------------------------------------------------------")

    # -------------------------------------------------------------------------
    # STEP 8: WAREHOUSE, VALIDATE, PURGE
    # -------------------------------------------------------------------------
    print("⏳ [8/8] Running analytical metrics calculation and data verification...")
    
    with open(os.path.join('db_init', '03_warehouse.sql'), 'r', encoding='utf-8') as f:
        cursor.execute(f.read())
        
    with open(os.path.join('db_init', '05_validation.sql'), 'r', encoding='utf-8') as f:
        cursor.execute(f.read())
        
    with open(os.path.join('db_init', '04_purge_staging.sql'), 'r', encoding='utf-8') as f:
        cursor.execute(f.read())
        
    conn.commit()
    print("✅ Warehouse calculations and validation checks complete.\n")

    print("=========================================================================")
    print("🎉 SUCCESS: Pipeline processing cycle completed successfully!")
    print("=========================================================================")

except Exception as e:
    conn.rollback()
    print(f"\n❌ Pipeline aborted due to error: {e}")
    sys.exit(1)

finally:
    cursor.close()
    conn.close()
    print("🔒 System database transaction network interface safely closed.")