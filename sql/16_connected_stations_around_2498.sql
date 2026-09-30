-- GoogleSQL (BigQuery). Extracted from the team SQL PDF.
-- Requires access to the original project tables; results have not been rerun.

/* ============================================================================
  16_CONNECTED_STATIONS_AROUND_2498
  Purpose:
  Find the strongest ride connections from station 2498.
  This supports the relationship-between-stations and route analysis.
============================================================================ */

WITH cleaned_rentals AS (
 SELECT DISTINCT
   r.trip_id,
   r.start_station_id,
   r.end_station_id,
   TRIM(r.end_station_name) AS end_station_name,
   CAST(r.start_time AS TIMESTAMP) AS start_time,
   CAST(r.duration_minutes AS INT64) AS duration_minutes
 FROM `bqproj-488319.zen_city.rentals` r
 WHERE
   CAST(r.start_time AS TIMESTAMP) >= '2022-01-01 00:00:00'
   AND CAST(r.start_time AS TIMESTAMP) < '2022-04-01 00:00:00'
   AND r.trip_id IS NOT NULL
   AND r.start_station_id IS NOT NULL

     AND r.end_station_id IS NOT NULL
     AND CAST(r.duration_minutes AS INT64) >= 2
     AND CAST(r.duration_minutes AS INT64) <= 1440
)
SELECT
 end_station_id AS connected_station_id,
 end_station_name AS connected_station_name,
 COUNT(*) AS total_connected_trips,
 ROUND(AVG(duration_minutes), 1) AS avg_trip_duration_minutes
FROM cleaned_rentals
WHERE
 start_station_id = 2498
 AND end_station_id != 2498
GROUP BY connected_station_id, connected_station_name
ORDER BY total_connected_trips DESC
LIMIT 5;
