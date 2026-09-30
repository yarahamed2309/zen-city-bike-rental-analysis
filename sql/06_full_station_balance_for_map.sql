-- GoogleSQL (BigQuery). Extracted from the team SQL PDF.
-- Requires access to the original project tables; results have not been rerun.

/* ============================================================================
    06_FULL_STATION_BALANCE_FOR_MAP
    Purpose:
    Return all stations with source/sink status and imbalance magnitude.
    Export this result to CSV for the Colab/Folium map.
============================================================================ */

WITH cleaned_rentals AS (
 SELECT DISTINCT
     r.trip_id,
     TRIM(r.start_station_name) AS start_station_name,
     TRIM(r.end_station_name) AS end_station_name,

     CAST(r.start_time AS TIMESTAMP) AS start_time,
     CAST(r.duration_minutes AS INT64) AS duration_minutes
 FROM `bqproj-488319.zen_city.rentals` r
 WHERE
     CAST(r.start_time AS TIMESTAMP) >= '2022-01-01 00:00:00'
     AND CAST(r.start_time AS TIMESTAMP) < '2022-04-01 00:00:00'
     AND r.trip_id IS NOT NULL
     AND r.start_station_name IS NOT NULL
     AND r.end_station_name IS NOT NULL
     AND CAST(r.duration_minutes AS INT64) >= 2
     AND CAST(r.duration_minutes AS INT64) <= 1440
),
station_departures AS (
 SELECT start_station_name AS station_name, COUNT(trip_id) AS total_departures
 FROM cleaned_rentals
 GROUP BY start_station_name
),
station_arrivals AS (
 SELECT end_station_name AS station_name, COUNT(trip_id) AS total_arrivals
 FROM cleaned_rentals
 GROUP BY end_station_name
)
SELECT
 COALESCE(d.station_name, a.station_name) AS station_name,
 COALESCE(d.total_departures, 0) AS total_departures,
 COALESCE(a.total_arrivals, 0) AS total_arrivals,
 COALESCE(a.total_arrivals, 0) - COALESCE(d.total_departures, 0) AS net_bike_flow,
 CASE
     WHEN COALESCE(a.total_arrivals, 0) - COALESCE(d.total_departures, 0) > 0
      THEN 'Sink (Accumulates Bikes)'
     WHEN COALESCE(a.total_arrivals, 0) - COALESCE(d.total_departures, 0) < 0
      THEN 'Source (Drains Bikes)'
     ELSE 'Balanced'
 END AS station_state,
 ABS(COALESCE(a.total_arrivals, 0) - COALESCE(d.total_departures, 0)) AS
imbalance_magnitude
FROM station_departures d
FULL OUTER JOIN station_arrivals a
 ON d.station_name = a.station_name
WHERE COALESCE(d.station_name, a.station_name) IS NOT NULL
ORDER BY imbalance_magnitude DESC;
