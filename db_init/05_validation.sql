SELECT 'Clean Layer Table' as layer, COUNT(*) FROM clean.annonces
UNION ALL
SELECT 'BI Fact Table Matrix' as layer, COUNT(*) FROM bi_schema.fact_annonces;