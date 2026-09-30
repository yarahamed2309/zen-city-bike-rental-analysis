-- GoogleSQL (BigQuery). Extracted from the team SQL PDF.
-- Requires access to the original project tables; results have not been rerun.

/* ============================================================================
  01_DATA_CLEANING_AND_FEATURE_ENGINEERING
  Purpose:
  Create a clean, enriched rental table for analysis.
  Use this query to preview the cleaned data structure and engineered fields.
============================================================================ */

WITH cleaned_rentals AS (
 SELECT DISTINCT
   trip_id,
   customer_id,
   bike_id,
   bike_type,

   -- Standardize customer segment text
   COALESCE(INITCAP(TRIM(subscriber_type)), 'Casual Rider') AS subscriber_type,

   -- Station information
   start_station_id,
   TRIM(start_station_name) AS start_station_name,
   end_station_id,
   TRIM(end_station_name) AS end_station_name,

     -- Duration and timestamp fields
     CAST(duration_minutes AS INT64) AS duration_minutes,
     CAST(start_time AS TIMESTAMP) AS start_time,

     -- Date/time features for analysis
     DATE(CAST(start_time AS TIMESTAMP)) AS trip_date,
     EXTRACT(MONTH FROM CAST(start_time AS TIMESTAMP)) AS trip_month,
     EXTRACT(DAYOFWEEK FROM CAST(start_time AS TIMESTAMP)) AS day_of_week,
     EXTRACT(HOUR FROM CAST(start_time AS TIMESTAMP)) AS trip_hour,

     CASE
      WHEN EXTRACT(DAYOFWEEK FROM CAST(start_time AS TIMESTAMP)) IN (1, 7)
         THEN 'Weekend'
      ELSE 'Weekday'
     END AS day_type

 FROM `bqproj-488319.zen_city.rentals`
 WHERE
     CAST(start_time AS TIMESTAMP) >= '2022-01-01 00:00:00'
     AND CAST(start_time AS TIMESTAMP) < '2022-04-01 00:00:00'
     AND trip_id IS NOT NULL
     AND CAST(duration_minutes AS INT64) >= 2
     AND CAST(duration_minutes AS INT64) <= 1440
)
SELECT *
FROM cleaned_rentals;
