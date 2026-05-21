import os
import psycopg2
from dotenv import load_dotenv

# Load database environment variables
load_dotenv()

def get_db_connection():
    """Establishes and returns a connection instance to the local PostgreSQL warehouse."""
    try:
        conn = psycopg2.connect(
            host=os.getenv('DB_HOST'),
            port=os.getenv('DB_PORT'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD'),
            database=os.getenv('DB_NAME')
        )
        return conn
    except Exception as e:
        print(f"❌ Database Connection Failed: {e}")
        raise e