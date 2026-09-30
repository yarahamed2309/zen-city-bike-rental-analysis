-- GoogleSQL (BigQuery). Extracted from the team SQL PDF.
-- Requires access to the original project tables; results have not been rerun.

/* ============================================================================
    05_TOP_5_SOURCES_AND_TOP_5_SINKS
    Purpose:
    Identify the stations with the strongest imbalance.
    - Sink: arrivals > departures, station accumulates bikes
    - Source: departures > arrivals, station drains bikes

    This is the main query for the Source/Sink analysis slide.
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
 SELECT
     start_station_name AS station_name,
     COUNT(trip_id) AS total_departures
 FROM cleaned_rentals
 GROUP BY start_station_name
),
station_arrivals AS (
 SELECT
     end_station_name AS station_name,
     COUNT(trip_id) AS total_arrivals
 FROM cleaned_rentals
 GROUP BY end_station_name
),
combined_metrics AS (
 SELECT
     COALESCE(d.station_name, a.station_name) AS station_name,
     COALESCE(d.total_departures, 0) AS total_departures,
     COALESCE(a.total_arrivals, 0) AS total_arrivals,
     COALESCE(a.total_arrivals, 0) - COALESCE(d.total_departures, 0) AS net_bike_flow
 FROM station_departures d
 FULL OUTER JOIN station_arrivals a
     ON d.station_name = a.station_name
),
ranked_stations AS (
 SELECT
     station_name,
     total_departures,
     total_arrivals,
     net_bike_flow,
     ABS(net_bike_flow) AS imbalance_magnitude,
     ROW_NUMBER() OVER (ORDER BY net_bike_flow DESC) AS sink_rank,

     ROW_NUMBER() OVER (ORDER BY net_bike_flow ASC) AS source_rank
 FROM combined_metrics
 WHERE net_bike_flow != 0
)
SELECT
 station_name,
 total_departures,
 total_arrivals,
 net_bike_flow,
 imbalance_magnitude,
 'Sink (Accumulates Bikes)' AS station_state,
 sink_rank AS state_rank
FROM ranked_stations
WHERE sink_rank <= 5

UNION ALL

SELECT
 station_name,
 total_departures,
 total_arrivals,
 net_bike_flow,
 imbalance_magnitude,
 'Source (Drains Bikes)' AS station_state,
 source_rank AS state_rank
FROM ranked_stations
WHERE source_rank <= 5
ORDER BY station_state DESC, net_bike_flow DESC;
