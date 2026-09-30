-- GoogleSQL (BigQuery). Extracted from the team SQL PDF.
-- Requires access to the original project tables; results have not been rerun.

/* ============================================================================
    11_AVERAGE_DURATION_FOR_EXTREME_STATIONS
    Purpose:
    Compare ride duration for trips leaving the top draining stations and trips
    arriving at the top overflowing stations.
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

),
station_net_flows AS (
 SELECT
     station_name,
     COALESCE(arrivals, 0) - COALESCE(departures, 0) AS net_bike_flow
 FROM (
     SELECT start_station_name AS station_name, COUNT(trip_id) AS departures
     FROM cleaned_rentals
     WHERE start_station_name != 'Unknown Station'
     GROUP BY start_station_name
 ) d
 FULL OUTER JOIN (
     SELECT end_station_name AS station_name, COUNT(trip_id) AS arrivals
     FROM cleaned_rentals
     WHERE end_station_name != 'Unknown Station'
     GROUP BY end_station_name
 ) a
 USING (station_name)
),
top_negative AS (
 SELECT station_name, net_bike_flow
 FROM station_net_flows
 ORDER BY net_bike_flow ASC
 LIMIT 5
),
top_positive AS (
 SELECT station_name, net_bike_flow
 FROM station_net_flows
 ORDER BY net_bike_flow DESC
 LIMIT 5
),
negative_duration AS (
 SELECT
     'Top 5 Negative (Draining Stations)' AS station_group,
     r.start_station_name AS station_name,
     n.net_bike_flow,
     'Departures (Trips Starting Here)' AS measured_metric,
     COUNT(r.trip_id) AS total_trips,
     ROUND(AVG(r.duration_minutes), 1) AS avg_duration_minutes
 FROM cleaned_rentals r
 JOIN top_negative n
     ON r.start_station_name = n.station_name

 GROUP BY r.start_station_name, n.net_bike_flow
),
positive_duration AS (
 SELECT
     'Top 5 Positive (Overflowing Stations)' AS station_group,
     r.end_station_name AS station_name,
     p.net_bike_flow,
     'Arrivals (Trips Ending Here)' AS measured_metric,
     COUNT(r.trip_id) AS total_trips,
     ROUND(AVG(r.duration_minutes), 1) AS avg_duration_minutes
 FROM cleaned_rentals r
 JOIN top_positive p
     ON r.end_station_name = p.station_name
 GROUP BY r.end_station_name, p.net_bike_flow
)
SELECT * FROM negative_duration
UNION ALL
SELECT * FROM positive_duration
ORDER BY station_group DESC, net_bike_flow ASC;
