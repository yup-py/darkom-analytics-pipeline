import os
import sys
import time
from utils.setup_db import initialize_database_and_tables
from utils.db_connect import get_db_connection
from utils.extract_load import load_csv_to_staging

print("=========================================================================")
print("📥 RUNNING RAW INGESTION ONLY (DEBUG MODE)")
print("=========================================================================\n")

# 1. Initialize Database Structural Elements
print("⏳ [1/2] Verifying database infrastructure setup...")
try:
    initialize_database_and_tables()
    print("✅ Infrastructure ready.\n")
except Exception as e:
    print(f"❌ Initialization failed: {e}")
    sys.exit(1)

# 2. Connect and Stream CSV directly to Staging
conn = get_db_connection()
cursor = conn.cursor()

try:
    csv_file_path = os.path.join('data', 'raw', 'darkom_annonces.csv') 
    print("⏳ [2/2] Ingesting raw CSV records directly into Staging Layer...")
    start_time = time.time()
    
    load_csv_to_staging(conn, csv_file_path)
    conn.commit()
    
    print(f"✅ Ingestion successful ({time.time() - start_time:.2f}s).")
    print("🚀 Data is now parked in 'staging.raw_annonces'. Ready for step-by-step cleaning!")

except Exception as e:
    conn.rollback()
    print(f"❌ Raw ingestion failed: {e}")
finally:
    cursor.close()
    conn.close()