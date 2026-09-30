-- GoogleSQL (BigQuery). Extracted from the team SQL PDF.
-- Requires access to the original project tables; results have not been rerun.

/* ============================================================================
    08_TOP_ROUTE_FLOWS
    Purpose:
    Identify the most common start-to-end station pairs.
    This explains the relationship between stations and main movement corridors.
============================================================================ */

WITH cleaned_rentals AS (
 SELECT DISTINCT
     r.trip_id,
     COALESCE(TRIM(r.start_station_name), 'Unknown Station') AS start_station_name,
     COALESCE(TRIM(r.end_station_name), 'Unknown Station') AS end_station_name,
     CAST(r.duration_minutes AS INT64) AS duration_minutes
 FROM `bqproj-488319.zen_city.rentals` r
 WHERE
     CAST(r.start_time AS TIMESTAMP) >= '2022-01-01 00:00:00'
     AND CAST(r.start_time AS TIMESTAMP) < '2022-04-01 00:00:00'
     AND r.trip_id IS NOT NULL
     AND CAST(r.duration_minutes AS INT64) >= 2
     AND CAST(r.duration_minutes AS INT64) <= 1440
)
SELECT
 start_station_name AS start_station,
 end_station_name AS end_station,
 COUNT(trip_id) AS total_trips_on_route,
 ROUND(AVG(duration_minutes), 1) AS avg_duration_minutes

FROM cleaned_rentals
WHERE
 start_station_name != 'Unknown Station'
 AND end_station_name != 'Unknown Station'
 AND start_station_name != end_station_name
GROUP BY start_station_name, end_station_name
ORDER BY total_trips_on_route DESC
LIMIT 20;
