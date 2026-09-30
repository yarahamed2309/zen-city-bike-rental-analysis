-- GoogleSQL (BigQuery). Extracted from the team SQL PDF.
-- Requires access to the original project tables; results have not been rerun.

/* ============================================================================
    03_PEAK_TIMES_AND_SEASONALITY
    Purpose:
    Identify the busiest months, days, and hours.
    Use this to explain when demand is highest and when operations should prepare.
============================================================================ */

WITH cleaned_rentals AS (
 SELECT DISTINCT
     r.trip_id,
     CAST(r.start_time AS TIMESTAMP) AS start_time,
     CAST(r.duration_minutes AS INT64) AS duration_minutes,
     EXTRACT(MONTH FROM CAST(r.start_time AS TIMESTAMP)) AS trip_month,
     EXTRACT(DAYOFWEEK FROM CAST(r.start_time AS TIMESTAMP)) AS trip_day_of_week,
     EXTRACT(HOUR FROM CAST(r.start_time AS TIMESTAMP)) AS trip_hour
 FROM `bqproj-488319.zen_city.rentals` r
 WHERE
     CAST(r.start_time AS TIMESTAMP) >= '2022-01-01 00:00:00'
     AND CAST(r.start_time AS TIMESTAMP) < '2022-04-01 00:00:00'
     AND r.trip_id IS NOT NULL
     AND CAST(r.duration_minutes AS INT64) >= 2
     AND CAST(r.duration_minutes AS INT64) <= 1440
)

SELECT
 trip_month AS month,
 CASE trip_day_of_week
     WHEN 1 THEN '1. Sunday'
     WHEN 2 THEN '2. Monday'
     WHEN 3 THEN '3. Tuesday'
     WHEN 4 THEN '4. Wednesday'
     WHEN 5 THEN '5. Thursday'
     WHEN 6 THEN '6. Friday'
     WHEN 7 THEN '7. Saturday'
 END AS day_of_week,
 trip_hour AS hour_of_day,
 COUNT(trip_id) AS total_rentals,
 ROUND(AVG(duration_minutes), 1) AS avg_duration_minutes
FROM cleaned_rentals
GROUP BY month, day_of_week, hour_of_day
ORDER BY total_rentals DESC;
