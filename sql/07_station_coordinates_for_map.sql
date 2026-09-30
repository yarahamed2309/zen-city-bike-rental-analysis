-- GoogleSQL (BigQuery). Extracted from the team SQL PDF.
-- Requires access to the original project tables; results have not been rerun.

/* ============================================================================
    07_STATION_COORDINATES_FOR_MAP
    Purpose:
    Export active station coordinates from the public Austin Bikeshare station table.
    Use this result as station_info.csv in Colab.
============================================================================ */

SELECT
 name AS station_name,
 SAFE_CAST(SPLIT(TRIM(location, '()'), ', ')[SAFE_OFFSET(0)] AS FLOAT64) AS latitude,
 SAFE_CAST(SPLIT(TRIM(location, '()'), ', ')[SAFE_OFFSET(1)] AS FLOAT64) AS longitude
FROM `bigquery-public-data.austin_bikeshare.bikeshare_stations`
WHERE status = 'active';
