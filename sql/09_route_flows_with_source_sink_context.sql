-- GoogleSQL (BigQuery). Extracted from the team SQL PDF.
-- Requires access to the original project tables; results have not been rerun.

/* ============================================================================
  09_ROUTE_FLOWS_WITH_SOURCE_SINK_CONTEXT
  Purpose:
  Show top routes together with the net balance of their start and end stations.
  This connects route behavior to the source/sink imbalance problem.
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
)
SELECT
 r.start_station_name AS start_station,
 s_start.net_bike_flow AS start_station_net_balance,
 r.end_station_name AS end_station,
 s_end.net_bike_flow AS end_station_net_balance,
 COUNT(r.trip_id) AS total_trips_on_route,
 ROUND(AVG(r.duration_minutes), 1) AS avg_duration_minutes
FROM cleaned_rentals r
JOIN station_net_flows s_start
 ON r.start_station_name = s_start.station_name
JOIN station_net_flows s_end
 ON r.end_station_name = s_end.station_name
WHERE
 r.start_station_name != 'Unknown Station'
 AND r.end_station_name != 'Unknown Station'
 AND r.start_station_name != r.end_station_name
GROUP BY
 r.start_station_name,
 s_start.net_bike_flow,
 r.end_station_name,
 s_end.net_bike_flow
ORDER BY total_trips_on_route DESC
LIMIT 20;
