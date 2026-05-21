import os
import psycopg2
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
from dotenv import load_dotenv

load_dotenv()

def initialize_database_and_tables():
    """Checks for database presence and runs core framework structural initialization."""
    print("⏳ Checking system database infrastructure setup...")
    
    db_name = os.getenv('DB_NAME')
    
    # 1. Connect to default administration server context to check database existence
    conn_default = psycopg2.connect(
        host=os.getenv('DB_HOST'),
        port=os.getenv('DB_PORT'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD'),
        database='postgres' 
    )
    conn_default.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
    cursor = conn_default.cursor()
    
    # Check if target analytical warehouse already exists
    cursor.execute(f"SELECT 1 FROM pg_catalog.pg_database WHERE datname = '{db_name}'")
    if not cursor.fetchone():
        print(f"⚙️ Database '{db_name}' not found. Initializing storage instance...")
        cursor.execute(f'CREATE DATABASE {db_name}')
    else:
        print(f"   Database '{db_name}' structural verification clear.")
        
    cursor.close()
    conn_default.close()

    # 2. Deploy basic structural table framework
    conn_darkom = psycopg2.connect(
        host=os.getenv('DB_HOST'),
        port=os.getenv('DB_PORT'),
        user=os.getenv('DB_USER'),
        password=os.getenv('DB_PASSWORD'),
        database=db_name
    )
    
    sql_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'db_init'))
    file_path = os.path.join(sql_dir, '01_init.sql')
    
    try:
        with conn_darkom.cursor() as cursor:
            if os.path.exists(file_path):
                print("   Executing framework migration file: 01_init.sql")
                with open(file_path, 'r', encoding='utf-8') as f:
                    query = f.read().strip()
                    if query:
                        cursor.execute(query)
                print("   ✅ All schema migration structures applied without faults.")
            else:
                print("⚠️ Warning: Core initialization file 01_init.sql was not detected.")
                    
        conn_darkom.commit()
    except Exception as e:
        conn_darkom.rollback()
        print(f"❌ Setup Migration Sequence Failed: {e}")
        raise e
    finally:
        conn_darkom.close()