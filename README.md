# 🏠 Darkom Analytics Pipeline

A production-grade **data warehouse and business intelligence solution** for the Moroccan real estate platform **Darkom.ma**. This project transforms raw real estate listing data into an enterprise-ready analytics ecosystem.

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Technology Stack](#technology-stack)
4. [Project Structure](#project-structure)
5. [Setup &amp; Installation](#setup--installation)
6. [Pipeline Execution](#pipeline-execution)
7. [ELT Transformation Stages (In-Database)](#elt-transformation-stages-in-database)
8. [Data Warehouse Schema](#data-warehouse-schema)
9. [Power BI Integration](#power-BI-integration)
10. [Dashboards](#dashboards)
11. [Monitoring &amp; Validation](#monitoring--validation)
12. [Troubleshooting](#troubleshooting)
13. [Contributing](#contributing)

---

## 🎯 Overview

**Darkom.ma** is Morocco's leading real estate marketplace. This project implements an **industrialized ELT pipeline** that:

- ✅ Ingests diverse real estate data from CSV sources
- ✅ Applies rigorous data cleaning, standardization, and validation
- ✅ Constructs a dimensional data warehouse optimized for analytics
- ✅ Feeds Power BI dashboards with business intelligence capabilities
- ✅ Ensures data quality through automated validation checks

> **Why ELT?** This pipeline follows the **ELT (Extract → Load → Transform)** pattern: raw CSV data is first extracted and loaded as-is into a PostgreSQL staging layer (all columns stored as TEXT), and all transformation logic — cleaning, type casting, imputation, feature engineering, and dimensional modeling — is executed **inside the database** using SQL. This leverages PostgreSQL's native processing power and keeps transformations auditable, version-controlled, and replayable without re-ingesting data.

**Key Achievements:**

- Processes 1000s of real estate listings
- Handles missing values through intelligent imputation
- Detects and removes outliers based on domain rules
- Generates 4 interactive Power BI dashboards
- Supports real-time market analysis and trends

---

## 🏗️ Architecture

```
┌─────────────────┐
│  Raw CSV Data   │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│  PostgreSQL (Staging)   │  ← Raw data ingestion (all TEXT)
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────────────┐
│  Clean Layer (ELT Transforms)   │  ← 5-step modular cleaning
├─────────────────────────────────┤
│ 01. Standardization             │
│ 02. Outlier Detection           │
│ 03. Missing Value Imputation    │
│ 04. Type Conversion             │
│ 05. Feature Engineering         │
└────────┬────────────────────────┘
         │
         ▼
┌──────────────────────────┐
│  Production Clean Table  │  ← Final validated dataset
└────────┬─────────────────┘
         │
         ▼
┌───────────────────────────────────┐
│  BI Data Warehouse (Star Schema)  │  ← Dimensional modeling
├───────────────────────────────────┤
│ • Dimension Tables (Time, Location)
│ • Fact Table (Metrics)            │
│ • Indexes & Relationships         │
└────────┬────────────────────────┘
         │
         ▼
┌────────────────────────────┐
│  Power BI Dashboards (4)   │  ← Business Intelligence
├────────────────────────────┤
│ 1. Global Market Overview  │
│ 2. Price Analysis          │
│ 3. Geographic Distribution │
│ 4. Market Trends           │
└────────────────────────────┘
```

---

## 🛠️ Technology Stack

| Component                         | Technology         | Version    |
| --------------------------------- | ------------------ | ---------- |
| **Database**                | PostgreSQL         | 13+        |
| **Data Processing**         | Python             | 3.8+       |
| **Orchestration**           | Python Scripts     | Custom ELT |
| **BI Tool**                 | Microsoft Power BI | Latest     |
| **Query Language**          | SQL                | Standard   |
| **Transformation Language** | DAX                | Power BI   |
| **CSV Processing**          | Pandas             | 3.0.3      |
| **Database Driver**         | psycopg2           | 2.9.12     |

---

## 📁 Project Structure

```
darkom-analytics-pipeline/
├── 📂 data/
│   ├── raw/
│   │   └── darkom_annonces.csv          # Source data (13 columns)
│   └── processed/
│       └── clean_annonces.csv           # Output clean dataset
│
├── 📂 db_init/
│   ├── 01_init.sql                      # Database & schema initialization
│   ├── 03_warehouse.sql                 # BI warehouse star schema
│   ├── 04_purge_staging.sql             # Cleanup intermediate tables
│   ├── 05_validation.sql                # Data quality checks
│   │
│   └── 📂 cleaning/
│       ├── 01_standardize.sql           # Text normalization & formatting
│       ├── 02_outliers.sql              # Domain-based outlier detection
│       ├── 03_missing_values.sql        # Imputation strategy
│       ├── 04_type_conversion.sql       # Safe type casting
│       └── 05_feature_engineering.sql   # Derived metrics creation
│
├── 📂 power_BI/
│   ├── darkom analytics.pbix            # Main Power BI report
│   ├── dax_measures.dax                 # DAX formulas & calculations
│   │
│   └── 📂 screenshots/
│       ├── 01_global_market.png         # Dashboard 1
│       ├── 02_price_analysis.png        # Dashboard 2
│       ├── 03_geographical.png          # Dashboard 3
│       └── 04_trends.png                # Dashboard 4
│
├── 📂 utils/
│   ├── __init__.py                      # Package initialization
│   ├── db_connect.py                    # Database connection handler
│   ├── setup_db.py                      # Schema initialization
│   └── extract_load.py                  # CSV loading utilities
│
├── run_pipeline.py                      # Main execution script (8 steps)
├── requirements.txt                     # Python dependencies
├── .env                                 # Environment configuration
└── .gitignore                           # Git ignore rules
```

---

## 🚀 Setup & Installation

### Prerequisites

- **PostgreSQL 13+** installed and running
- **Python 3.8+** installed
- **Git** (optional, for version control)
- **Power BI Desktop** (for dashboard visualization)

### Step 1: Clone the Repository

```bash
git clone <repository-url>
cd darkom-analytics-pipeline
```

### Step 2: Create PostgreSQL Database

```bash
createdb darkom_dwh
```

Or via PostgreSQL CLI:

```sql
CREATE DATABASE darkom_dwh;
```

### Step 3: Configure Environment Variables

Create/edit `.env` file in the project root:

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=darkom_dwh
DB_USER=postgres
DB_PASSWORD=your_password
```

⚠️ **Security Note:** Never commit `.env` to version control. Use environment variables in production.

### Step 4: Install Python Dependencies

```bash
pip install -r requirements.txt
```

**Key Dependencies:**

- `pandas==3.0.3` - Data manipulation
- `psycopg2-binary==2.9.12` - PostgreSQL adapter
- `python-dotenv==1.0.1` - Environment management
- `SQLAlchemy==2.0.30` - ORM toolkit

### Step 5: Verify PostgreSQL Connection

```bash
python -c "from utils.db_connect import get_db_connection; 
conn = get_db_connection(); 
print('✅ Connection successful!')"
```

---

## 🔄 Pipeline Execution

### Run Complete Pipeline (Recommended)

```bash
python run_pipeline.py
```

This executes all 8 steps automatically:

```
⏳ [1/8] Database schema initialization
⏳ [2/8] EXTRACT & LOAD: Raw CSV → staging.raw_annonces (ELT Phase 1 & 2)
⏳ [3/8] TRANSFORM: Standardization → clean_step1_standardized
⏳ [4/8] TRANSFORM: Outlier detection → clean_step2_outliers
⏳ [5/8] TRANSFORM: Missing value imputation → clean_step3_imputed
⏳ [6/8] TRANSFORM: Type conversion → clean_step4_typed
⏳ [7/8] TRANSFORM: Feature engineering → clean.annonces (PRODUCTION)
⏳ [EXTRA] Export clean data to CSV
⏳ [8/8] Warehouse construction & validation
✅ Pipeline complete
```

### Run Individual Steps

**Option A: Execute via PostgreSQL CLI**

```bash
psql -U postgres -d darkom_dwh -f db_init/01_init.sql
psql -U postgres -d darkom_dwh -f db_init/cleaning/01_standardize.sql
# ... and so on
```

**Option B: Execute via Python**

```python
from utils.setup_db import initialize_database_and_tables
from utils.db_connect import get_db_connection

initialize_database_and_tables()
conn = get_db_connection()
cursor = conn.cursor()

with open('db_init/cleaning/01_standardize.sql', 'r') as f:
    cursor.execute(f.read())
conn.commit()
```

---

## 🔀 ELT Transformation Stages (In-Database)

### Stage 1: Standardization (`01_standardize.sql`)

**Input:** Raw CSV with mixed casing and whitespace
**Output:** Consistent text formatting

**Transformations:**

- Trim whitespace from all fields
- Capitalize city names and property types (`INITCAP`)
- Extract date portion from timestamps (YYYY-MM-DD)
- Normalize transaction types: 'location', 'LOCATION' → 'Location'
- Preserve empty neighborhoods as NULL for imputation

**Example:**

```sql
Input:  "  marseille  " → Output: "Marseille"
Input:  "appartement" → Output: "Appartement"
Input:  "2025-03-15 14:30:45" → Output: "2025-03-15"
```

### Stage 2: Outlier Detection (`02_outliers.sql`)

**Input:** Standardized data
**Output:** Validated numeric ranges

**Rules Applied:**

```
Property Type     Bedrooms    Bathrooms   Floor    Price Range (Vente)       Price Range (Location)
─────────────────────────────────────────────────────────────────────────────────────────────────
Appartement       ≤ 8         ≤ 5         ≤ 25     80K - 15M MAD            400 - 60K MAD
Villa             ≤ 15        ≤ 10        0        80K - 15M MAD            400 - 60K MAD
Terrain           NULL        NULL        0        80K - 15M MAD            400 - 60K MAD
Bureau            ≤ 8         ≤ 5         ≤ 25     80K - 15M MAD            400 - 60K MAD
Duplex            ≤ 8         ≤ 5         ≤ 25     80K - 15M MAD            400 - 60K MAD
```

**Validation:**

- Surface must be > 0 m²
- Construction year between 1950-2026
- Case-insensitive type checks

### Stage 3: Missing Value Imputation (`03_missing_values.sql`)

**Input:** Cleaned data with nulls
**Output:** Fully imputed dataset

**Imputation Strategy:**

| Column                 | Strategy                          | Fallback                   |
| ---------------------- | --------------------------------- | -------------------------- |
| `quartier`           | Mode (most frequent by city)      | 'Centre Ville'             |
| `type_bien`          | Extract from title using keywords | 'Appartement'              |
| `nb_chambres`        | Median by type & surface bucket   | 2                          |
| `nb_salles_bain`     | Median by type & surface bucket   | 1                          |
| `etage`              | Median by city/neighborhood       | 1 (Apartments), 0 (Villas) |
| `annee_construction` | Median by city/neighborhood       | 2015                       |

**Example:** Forward-fill then backward-fill dates for publication dates

### Stage 4: Type Conversion (`04_type_conversion.sql`)

**Input:** Text fields
**Output:** Properly typed columns

**Conversions:**

```
date_publication_raw (TEXT)  → date_publication (DATE)
prix_raw (TEXT)              → prix (NUMERIC)
surface_raw (TEXT)           → surface (NUMERIC)
nb_chambres (TEXT/INT)       → nb_chambres (INT)
nb_salles_bain (TEXT/INT)    → nb_salles_bain (INT)
```

### Stage 5: Feature Engineering (`05_feature_engineering.sql`)

**Input:** Clean typed data
**Output:** Production table with derived metrics

**Features Created:**

```sql
-- 1. Price per Square Meter
price_per_m2 = ROUND(prix / surface, 2)

-- 2. Property Age
age_bien = 2026 - annee_construction

-- 3. Price Categories (Transaction-aware)
categorie_prix = 
  CASE WHEN transaction = 'Location'
    WHEN prix < 3000 THEN 'Économique'
    WHEN prix < 8000 THEN 'Moyen'
    WHEN prix < 15000 THEN 'Haut standing'
    ELSE 'Luxe'
  ELSE -- Vente
    WHEN prix < 600K THEN 'Économique'
    WHEN prix < 2M THEN 'Moyen'
    WHEN prix < 5M THEN 'Haut standing'
    ELSE 'Luxe'

-- 4. Surface Categories
categorie_surface =
  CASE
    WHEN surface < 80 THEN 'Petit (< 80 m²)'
    WHEN surface < 150 THEN 'Moyen (80-150 m²)'
    ELSE 'Grand (> 150 m²)'
```

---

## 🏪 Data Warehouse Schema

### Star Schema Architecture

```
                    ┌──────────────────────┐
                    │   dim_temps          │
                    ├──────────────────────┤
                    │ date_key (PK)        │
                    │ full_date            │
                    │ annee                │
                    │ mois                 │
                    │ nom_mois             │
                    │ trimestre            │
                    └──────────┬───────────┘
                               │
                    ┌──────────┴──────────┐
                    │                     │
    ┌───────────────▼──────────┐         │
    │ fact_annonces            │         │
    ├──────────────────────────┤         │
    │ annonce_id (PK)          │◄────────┘
    │ date_key (FK)            │
    │ loc_id (FK)──────┐       │
    │ carac_id (FK)──┐ │       │
    │ prix           │ │       │
    │ surface        │ │       │
    │ prix_m2        │ │       │
    │ nb_chambres    │ │       │
    │ nb_salles_bain │ │       │
    │ etage          │ │       │
    │ age_bien       │ │       │
    └────────────────┼─┼───────┘
                     │ │
        ┌────────────┘ │
        │              │
        │    ┌─────────┘
        │    │
    ┌───▼────▼─────────────────┐    ┌──────────────────────────┐
    │ dim_localisation          │    │ dim_caracteristiques     │
    ├───────────────────────────┤    ├──────────────────────────┤
    │ loc_id (PK)               │    │ carac_id (PK)            │
    │ ville                     │    │ type_bien                │
    │ quartier                  │    │ transaction              │
    │ UNIQUE (ville, quartier)  │    │ categorie_prix           │
    └───────────────────────────┘    │ categorie_surface        │
                                      │ UNIQUE (all columns)     │
                                      └──────────────────────────┘
```

### Database Schemas

```sql
├── staging (Temporary)
│   └── raw_annonces          -- Raw CSV data
│   └── clean_step1_*         -- Intermediate transformations
│   └── clean_step2_*         -- Outlier-checked data
│   └── clean_step3_*         -- Imputed values
│   └── clean_step4_*         -- Type-converted data
│
├── clean (Production)
│   └── annonces              -- Final validated dataset (16 columns)
│
└── bi_schema (Analytics)
    ├── dim_localisation       -- Location dimensions
    ├── dim_temps             -- Time dimensions  
    ├── dim_caracteristiques  -- Property characteristics
    └── fact_annonces         -- Central fact table
```

---

## 📊 Power BI Integration

### Connection Setup

1. **Open Power BI Desktop**
2. **Get Data → PostgreSQL Database**
3. **Enter credentials:**

   - Server: `localhost`
   - Database: `darkom_dwh`
   - Data Connectivity Mode: `Import`
4. **Select tables from `bi_schema`:**

   - `dim_temps`
   - `dim_localisation`
   - `dim_caracteristiques`
   - `fact_annonces`
5. **Create relationships:**

   - `fact_annonces.date_key` → `dim_temps.date_key`
   - `fact_annonces.loc_id` → `dim_localisation.loc_id`
   - `fact_annonces.carac_id` → `dim_caracteristiques.carac_id`

### Power Query Optimizations

- ✅ Change column types to match database schema
- ✅ Remove unnecessary text columns for model efficiency
- ✅ Create calculated columns for drill-down analysis
- ✅ Apply date formatting (DD/MM/YYYY)
- ✅ Filter outliers (if needed) before loading

### DAX Measures Created

**Volume Metrics:**

```dax
Total Active Listings = COUNTROWS('fact_annonces')
Property Type Share % = DIVIDE([Total Active Listings], 
                               CALCULATE([Total Active Listings], ALL(...)))
```

**Financial Metrics:**

```dax
Average Listing Price = AVERAGE('fact_annonces'[prix])
Average Price per m² = AVERAGE('fact_annonces'[prix_m2])
Avg Price per City = CALCULATE([Average Listing Price], 
                               ALLEXCEPT('dim_localisation', 'dim_localisation'[ville]))
```

**Structural Metrics:**

```dax
Average Surface Area (m²) = AVERAGE('fact_annonces'[surface])
```

**Time Intelligence:**

```dax
Listings Previous Year = CALCULATE([Total Active Listings], 
                                   DATEADD('dim_temps'[full_date], -1, YEAR))
YoY Ad Growth Rate = DIVIDE([Total Active Listings] - [Listings Previous Year], 
                            [Listings Previous Year])
```

---

## 📈 Dashboards

### Dashboard 1: Global Market Overview

**Purpose:** High-level market snapshot

**Visualizations:**

- 📊 **Total Listings (Card)** - Key metric
- 📊 **Average Market Price (Card)** - KPI
- 📊 **Average Surface Area (Card)** - Structural KPI
- 📊 **Listings by City (Bar Chart)** - Geographic distribution
- 📊 **Listings Over Time (Line Chart)** - Temporal trend
- 📊 **Property Type Distribution (Donut)** - Category breakdown
- 📊 **Vente vs Location Split (Donut)** - Transaction type

**Filters:** City, Property Type, Date Range, Transaction Type

### Dashboard 2: Price Analysis

**Purpose:** Pricing intelligence and segmentation

**Visualizations:**

- 📊 **Price Distribution (Histogram)** - Market spread
- 📊 **Price per m² (Scatter)** - Value assessment
- 📊 **Avg Price by Segment (Bar)** - Price categories
- 📊 **Price by Property Type (Bar)** - Type comparison
- 📊 **Price Category Breakdown (Donut)** - Segment share
- 📊 **Price Trend (Line)** - Historical movement

**Filters:** Price Range, Property Type, City, Surface Category

### Dashboard 3: Geographic Analysis

**Purpose:** Spatial market insights

**Visualizations:**

- 📊 **Map: Average Price by City (Filled Map)**
- 📊 **Top 10 Most Expensive Cities (Bar)**
- 📊 **Top Neighborhoods by Volume (Bar)**
- 📊 **Price Heatmap: City vs Neighborhood (Matrix)**
- 📊 **Listings Distribution by Region (Pie)**

**Filters:** City, Neighborhood, Price Range, Property Type

### Dashboard 4: Market Trends

**Purpose:** Temporal analysis and forecasting insights

**Visualizations:**

- 📊 **Price Evolution (Line, Multi-Year)** - Historical trend
- 📊 **Listing Volume Trend (Area Chart)** - Supply dynamics
- 📊 **Market Volatility (Combo)** - Price+Volume
- 📊 **Seasonal Patterns (Line by Month)** - Cyclical trends
- 📊 **YoY Comparison (Clustered Bar)** - Period-over-period
- 📊 **Growth Rate (KPI Card)** - Momentum indicator

**Filters:** Date Range, Property Type, City, Transaction Type

**Advanced Features:**

- ✅ Drill-through capability to property details
- ✅ Slicers for dynamic filtering
- ✅ Conditional formatting on key metrics
- ✅ Tooltips with detailed information

---

## ✅ Monitoring & Validation

### Data Quality Checks

```sql
-- Run after pipeline completion
SELECT 'Clean Layer Table' as layer, COUNT(*) as row_count 
FROM clean.annonces
UNION ALL
SELECT 'BI Fact Table' as layer, COUNT(*) as row_count 
FROM bi_schema.fact_annonces;
```

**Expected Output:**

```
layer                row_count
─────────────────────────────────
Clean Layer Table    12,500
BI Fact Table        12,500
```

### Validation Rules

| Check                       | Query                                                                                                                                       | Expected Result |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| **No duplicates**     | `SELECT COUNT(*) FROM clean.annonces WHERE annonce_id IN (SELECT annonce_id FROM clean.annonces GROUP BY annonce_id HAVING COUNT(*) > 1)` | 0               |
| **No NULL primaries** | `SELECT COUNT(*) FROM clean.annonces WHERE annonce_id IS NULL`                                                                            | 0               |
| **Valid dates**       | `SELECT COUNT(*) FROM clean.annonces WHERE date_publication > CURRENT_DATE`                                                               | 0               |
| **Positive prices**   | `SELECT COUNT(*) FROM clean.annonces WHERE prix <= 0`                                                                                     | 0               |
| **Valid surface**     | `SELECT COUNT(*) FROM clean.annonces WHERE surface <= 0`                                                                                  | 0               |
| **Completeness**      | `SELECT COUNT(*) FROM clean.annonces WHERE (ville IS NULL OR quartier IS NULL)`                                                           | 0               |

### Performance Monitoring

```sql
-- Check index usage
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM bi_schema.fact_annonces 
WHERE loc_id = 5;

-- Table size
SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables 
WHERE schemaname IN ('staging', 'clean', 'bi_schema')
ORDER BY pg_total_relation_size DESC;
```

---

## 🐛 Troubleshooting

### Common Issues & Solutions

#### ❌ "Connection refused (psycopg2.OperationalError)"

**Cause:** PostgreSQL not running or wrong credentials

**Solution:**

```bash
# Check PostgreSQL service
sudo systemctl status postgresql

# Start if needed
sudo systemctl start postgresql

# Verify connection
psql -U postgres -d darkom_dwh -c "SELECT version();"
```

#### ❌ "Table already exists"

**Cause:** Previous pipeline run didn't clean up

**Solution:**

```bash
# Full reset
psql -U postgres -d darkom_dwh -c "DROP SCHEMA staging CASCADE; DROP SCHEMA clean CASCADE; DROP SCHEMA bi_schema CASCADE;"

# Re-run pipeline
python run_pipeline.py
```

#### ❌ "CSV file not found"

**Cause:** Incorrect file path

**Solution:**

```bash
# Verify file exists
ls -la data/raw/darkom_annonces.csv

# Check working directory
pwd  # Should be project root
```

#### ❌ "Memory error during imputation"

**Cause:** Large dataset with window functions

**Solution:**

```sql
-- Run steps individually, commit after each
ANALYZE staging.clean_step2_outliers;  -- Update statistics
```

#### ❌ "Foreign key constraint violation in Power BI"

**Cause:** Dimension values missing in fact table

**Solution:**

```sql
-- Check for orphaned keys
SELECT DISTINCT f.loc_id 
FROM bi_schema.fact_annonces f
LEFT JOIN bi_schema.dim_localisation l ON f.loc_id = l.loc_id
WHERE l.loc_id IS NULL;

-- Rebuild warehouse
psql -U postgres -d darkom_dwh -f db_init/03_warehouse.sql
```

---

## 📚 Data Dictionary

### clean.annonces (Production Table)

| Column                 | Type         | Description                           | Example                        |
| ---------------------- | ------------ | ------------------------------------- | ------------------------------ |
| `annonce_id`         | VARCHAR(50)  | Unique listing identifier             | `DRK_2025_001234`            |
| `date_publication`   | DATE         | Publication date                      | `2025-03-15`                 |
| `ville`              | VARCHAR(100) | City name                             | `Casablanca`                 |
| `quartier`           | VARCHAR(150) | Neighborhood                          | `Ain Chock`                  |
| `type_bien`          | VARCHAR(100) | Property type                         | `Appartement`                |
| `transaction`        | VARCHAR(50)  | Transaction type                      | `Vente` or `Location`      |
| `prix`               | NUMERIC      | Price in MAD                          | `1250000` or `5500`        |
| `surface`            | NUMERIC      | Surface area in m²                   | `120.5`                      |
| `nb_chambres`        | INT          | Number of bedrooms                    | `3`                          |
| `nb_salles_bain`     | INT          | Number of bathrooms                   | `2`                          |
| `etage`              | INT          | Floor number                          | `2` or `0` (for villas)    |
| `annee_construction` | INT          | Construction year                     | `2015`                       |
| `price_per_m2`       | NUMERIC      | Calculated: prix / surface            | `10416.67`                   |
| `age_bien`           | INT          | Calculated: 2026 - annee_construction | `11`                         |
| `categorie_prix`     | VARCHAR(50)  | Price segment                         | `Moyen` or `Haut standing` |
| `categorie_surface`  | VARCHAR(50)  | Surface segment                       | `Petit (< 80 m²)`           |

### bi_schema.fact_annonces (BI Fact Table)

Contains all numerical metrics joined with dimension foreign keys:

- `annonce_id`, `date_key`, `loc_id`, `carac_id`, `prix`, `surface`, `prix_m2`, `nb_chambres`, `nb_salles_bain`, `etage`, `age_bien`

---

## 🔄 Maintenance & Updates

### Weekly Maintenance

```bash
# Analyze tables for query optimization
psql -U postgres -d darkom_dwh -c "ANALYZE clean.annonces; ANALYZE bi_schema.fact_annonces;"

# Check index fragmentation
psql -U postgres -d darkom_dwh -c "SELECT * FROM pg_stat_user_indexes WHERE idx_blks_read > 1000;"
```

### Monthly Archival

```sql
-- Archive old staging data (retain only recent)
DELETE FROM staging.raw_annonces WHERE loaded_at < CURRENT_DATE - INTERVAL '30 days';
```

### Quarterly Schema Audit

```sql
-- Verify referential integrity
SELECT 
    constraint_name,
    table_name,
    column_name
FROM information_schema.key_column_usage
WHERE table_schema = 'bi_schema'
ORDER BY table_name, constraint_name;
```

---

## 🤝 Contributing

Contributions are welcome! Follow these guidelines:

1. **Create a feature branch:** `git checkout -b feature/your-feature`
2. **Make changes** to SQL scripts or Python code
3. **Test thoroughly:**
   ```bash
   python run_pipeline.py  # Full pipeline test
   python -m pytest tests/  # Unit tests (if applicable)
   ```
4. **Commit with clear messages:** `git commit -m "feat: add new validation rule"`
5. **Push and create Pull Request**

### Code Standards

- ✅ SQL: Use consistent formatting, add comments for complex logic
- ✅ Python: Follow PEP 8, use type hints
- ✅ Documentation: Update README for new features
- ✅ Testing: Validate with real data samples

---

## 📝 License

This project is proprietary to Darkom.ma. Use and distribution are restricted.

---

## 📞 Support & Contact

For issues, questions, or feature requests:

- 📧 **Email:** analytics@darkom.ma
- 🐛 **Report Issues:** Create an issue in the repository
- 💬 **Slack Channel:** #data-warehouse-support

---

## 📚 Additional Resources

- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Power BI Documentation](https://docs.microsoft.com/en-us/power-bi/)
- [DAX Function Reference](https://dax.guide/)
- [SQL Best Practices for Analytics](https://www.brentozar.com/)

---

**Last Updated:** June 2025
**Version:** 1.0.0
**Maintained By:** Data Engineering Team

---

## 🎯 Quick Start (TL;DR)

```bash
# 1. Setup database & environment
createdb darkom_dwh
cp .env.example .env  # Configure credentials

# 2. Install dependencies
pip install -r requirements.txt

# 3. Run pipeline
python run_pipeline.py

# 4. Open Power BI
# Connect to darkom_dwh database
# Select bi_schema tables
# Enjoy dashboards! 📊
```

---

**Built for data-driven decision making in Moroccan real estate.**
