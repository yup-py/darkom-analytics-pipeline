import os
import csv

def load_csv_to_staging(conn, csv_path):
    """Streams data dynamically from the local CSV straight into the SQL staging table."""
    if not os.path.exists(csv_path):
        # This will now correctly output: Target CSV dataset missing at location: data/raw/darkom_annonces.csv
        raise FileNotFoundError(f"Target CSV dataset missing at location: {csv_path}")
        
    print(f"   Ingesting raw records from {csv_path} directly into Staging Layer...")
    
    with conn.cursor() as cursor:
        # Clear previous run data to ensure a fresh, pristine execution zone
        cursor.execute("TRUNCATE TABLE staging.raw_annonces CASCADE;")
        
        with open(csv_path, mode='r', encoding='utf-8') as f:
            reader = csv.reader(f)
            header = next(reader)  # Automatically skips the column header row
            
            # Dynamically handle placeholders based on the CSV column layout
            placeholders = ", ".join(["%s"] * len(header))
            insert_query = f"""
                INSERT INTO staging.raw_annonces (
                    annonce_id, date_publication, titre, ville, quartier, 
                    type_bien, transaction, prix, surface, nb_chambres, 
                    nb_salles_bain, etage, annee_construction
                ) VALUES ({placeholders});
            """
            
            batch = []
            for row in reader:
                batch.append(row)
                if len(batch) >= 1000:  # High-speed block processing
                    cursor.executemany(insert_query, batch)
                    batch = []
                    
            if batch:  # Flush out remaining data lines
                cursor.executemany(insert_query, batch)
                
    print("   ✅ Raw staging data ingestion successfully committed.")