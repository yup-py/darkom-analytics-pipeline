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


def export_clean_table_to_csv(conn, output_csv_path):
    """Fetches production data safely from clean.annonces and saves it as a local CSV."""
    output_dir = os.path.dirname(output_csv_path)
    if output_dir and not os.path.exists(output_dir):
        os.makedirs(output_dir, exist_ok=True)
        
    print(f"   ⏩ Exporting clean production records to: {output_csv_path}")
    
    # Using a clean, isolated cursor context to prevent any transaction conflicts
    with conn.cursor() as cursor:
        cursor.execute("""
            SELECT 
                annonce_id, date_publication, ville, quartier, type_bien, 
                transaction, prix, surface, nb_chambres, nb_salles_bain, 
                etage, annee_construction, price_per_m2, age_bien, 
                categorie_prix, categorie_surface 
            FROM clean.annonces;
        """)
        
        rows = cursor.fetchall()
        headers = [desc[0] for desc in cursor.description]
        
        with open(output_csv_path, mode='w', encoding='utf-8', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(headers)
            writer.writerows(rows)
            
    print(f"   ✅ Local CSV save complete! Total exported rows: {len(rows)}")