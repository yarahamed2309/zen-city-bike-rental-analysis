-- GoogleSQL (BigQuery). Extracted from the team SQL PDF.
-- Requires access to the original project tables; results have not been rerun.

/* ============================================================================
    02_DATA_QUALITY_OUTLIER_CHECK
    Purpose:
    Classify trips into valid rides and possible system/data-quality issues.
    This supports the data cleaning explanation in the project methodology.
============================================================================ */

WITH classified_rentals AS (
 SELECT
     r.trip_id,
     CAST(r.duration_minutes AS INT64) AS duration_minutes,
     CASE
      WHEN CAST(r.duration_minutes AS INT64) < 2
         THEN 'System Error: Faulty Bike / Instant Lock (<2 Min)'

      WHEN CAST(r.duration_minutes AS INT64) > 1440
         THEN 'System Error: Stolen / Forgotten Bike (>24 Hours)'
      ELSE 'Valid Ride'
     END AS ride_status
 FROM `bqproj-488319.zen_city.rentals` r
 WHERE
     CAST(r.start_time AS TIMESTAMP) >= '2022-01-01 00:00:00'
     AND CAST(r.start_time AS TIMESTAMP) < '2022-04-01 00:00:00'
     AND r.trip_id IS NOT NULL
)
SELECT
 ride_status,
 COUNT(trip_id) AS total_trips,
 ROUND(COUNT(trip_id) * 100.0 / SUM(COUNT(trip_id)) OVER(), 2) AS percentage_of_total
FROM classified_rentals
GROUP BY ride_status
ORDER BY total_trips DESC;
