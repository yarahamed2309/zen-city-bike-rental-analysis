-- GoogleSQL (BigQuery). Extracted from the team SQL PDF.
-- Requires access to the original project tables; results have not been rerun.

/* ============================================================================
  04_STATION_ACTIVITY_RANKING
  Purpose:
  Rank stations by total activity: departures + arrivals.
  This identifies the most used stations in the network.
============================================================================ */

WITH cleaned_rentals AS (
 SELECT DISTINCT
     r.trip_id,
     COALESCE(TRIM(r.start_station_name), 'Unknown Station') AS start_station_name,
     COALESCE(TRIM(r.end_station_name), 'Unknown Station') AS end_station_name
 FROM `bqproj-488319.zen_city.rentals` r
 WHERE
     CAST(r.start_time AS TIMESTAMP) >= '2022-01-01 00:00:00'
     AND CAST(r.start_time AS TIMESTAMP) < '2022-04-01 00:00:00'
     AND r.trip_id IS NOT NULL
     AND CAST(r.duration_minutes AS INT64) >= 2
     AND CAST(r.duration_minutes AS INT64) <= 1440
),
station_departures AS (
 SELECT
     start_station_name AS station_name,

     COUNT(trip_id) AS total_departures
 FROM cleaned_rentals
 WHERE start_station_name != 'Unknown Station'
 GROUP BY start_station_name
),
station_arrivals AS (
 SELECT
     end_station_name AS station_name,
     COUNT(trip_id) AS total_arrivals
 FROM cleaned_rentals
 WHERE end_station_name != 'Unknown Station'
 GROUP BY end_station_name
)
SELECT
 COALESCE(d.station_name, a.station_name) AS station_name,
 COALESCE(d.total_departures, 0) AS total_departures,
 COALESCE(a.total_arrivals, 0) AS total_arrivals,
 COALESCE(d.total_departures, 0) + COALESCE(a.total_arrivals, 0) AS
total_station_activity
FROM station_departures d
FULL OUTER JOIN station_arrivals a
 ON d.station_name = a.station_name
ORDER BY total_station_activity DESC;
