-- GoogleSQL (BigQuery). Extracted from the team SQL PDF.
-- Requires access to the original project tables; results have not been rerun.

/* ============================================================================
    12_TIME_OF_DAY_ANALYSIS_TOP_NEGATIVE_STATIONS
    Purpose:
    Break the top draining stations into morning, afternoon, and evening windows.
    Results are normalized to average weekly departures/arrivals.
============================================================================ */

WITH cleaned_rentals AS (
 SELECT DISTINCT
     r.trip_id,
     TRIM(r.start_station_name) AS start_station_name,
     TRIM(r.end_station_name) AS end_station_name,
     CAST(r.start_time AS TIMESTAMP) AS start_time,
     CAST(r.duration_minutes AS INT64) AS duration_minutes,
     EXTRACT(HOUR FROM CAST(r.start_time AS TIMESTAMP)) AS start_hour
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
negative_stations AS (
 SELECT 'Dean Keeton/Speedway' AS station_name UNION ALL
 SELECT '21st/Guadalupe' UNION ALL
 SELECT '23rd/San Gabriel' UNION ALL
 SELECT '28th/Rio Grande' UNION ALL
 SELECT '22nd/Pearl'
),
rentals_with_time_of_day AS (
 SELECT
     start_station_name,
     end_station_name,
     trip_id,
     CASE
      WHEN start_hour >= 6 AND start_hour < 12 THEN 'Morning (06:00-12:00)'
      WHEN start_hour >= 12 AND start_hour < 17 THEN 'Afternoon (12:00-17:00)'
      WHEN start_hour >= 17 AND start_hour <= 23 THEN 'Evening (17:00-00:00)'
      ELSE 'Night (00:00-06:00)'
     END AS time_of_day
 FROM cleaned_rentals
),
station_time_traffic AS (
 SELECT
     ns.station_name,
     t.time_of_day,
     COUNT(CASE WHEN r.start_station_name = ns.station_name THEN r.trip_id END) AS
departures,
     COUNT(CASE WHEN r.end_station_name = ns.station_name THEN r.trip_id END) AS
arrivals
 FROM negative_stations ns
 CROSS JOIN (SELECT DISTINCT time_of_day FROM rentals_with_time_of_day) t
 LEFT JOIN rentals_with_time_of_day r
     ON (r.start_station_name = ns.station_name OR r.end_station_name = ns.station_name)
     AND r.time_of_day = t.time_of_day
 GROUP BY ns.station_name, t.time_of_day
)
SELECT
 CONCAT(station_name, ' - ', time_of_day) AS station_and_time_of_day,
 station_name,

 time_of_day,
 ROUND(departures / 12.0, 1) AS avg_weekly_departures,
 ROUND(arrivals / 12.0, 1) AS avg_weekly_arrivals,
 ROUND((arrivals - departures) / 12.0, 1) AS avg_weekly_net_flow
FROM station_time_traffic
WHERE time_of_day != 'Night (00:00-06:00)'
ORDER BY
 station_name ASC,
 CASE
     WHEN time_of_day LIKE 'Morning%' THEN 1
     WHEN time_of_day LIKE 'Afternoon%' THEN 2
     WHEN time_of_day LIKE 'Evening%' THEN 3
 END ASC;
