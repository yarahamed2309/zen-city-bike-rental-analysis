-- GoogleSQL (BigQuery). Extracted from the team SQL PDF.
-- Requires access to the original project tables; results have not been rerun.

/* ============================================================================
    15_WEEKLY_FLOW_FOR_KEY_STATIONS
    Purpose:
    Analyze weekly departures, arrivals, and net flow for key stations.
    This replaces repeated station-specific queries with one reusable query.
============================================================================ */

WITH cleaned_rentals AS (
 SELECT DISTINCT
     r.trip_id,
     TRIM(r.start_station_name) AS start_station_name,
     TRIM(r.end_station_name) AS end_station_name,

     CAST(r.start_time AS TIMESTAMP) AS start_time,
     CAST(r.duration_minutes AS INT64) AS duration_minutes,
     EXTRACT(DAYOFWEEK FROM CAST(r.start_time AS TIMESTAMP)) AS day_number
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
target_stations AS (
 SELECT '21st/Speedway @ PCL' AS station_label, '%21st%' AS keyword_1, '%Speedway%' AS
keyword_2 UNION ALL
 SELECT 'Dean Keeton/Speedway', '%Dean Keeton%', '%Speedway%' UNION ALL
 SELECT '21st/Guadalupe', '%21st%', '%Guadalupe%' UNION ALL
 SELECT '23rd/San Gabriel', '%23rd%', '%San Gabriel%' UNION ALL
 SELECT '28th/Rio Grande', '%28th%', '%Rio Grande%' UNION ALL
 SELECT '22nd/Pearl', '%22nd%', '%Pearl%'
)
SELECT
 ts.station_label,
 cr.day_number,
 CASE cr.day_number
     WHEN 1 THEN 'Sunday'
     WHEN 2 THEN 'Monday'
     WHEN 3 THEN 'Tuesday'
     WHEN 4 THEN 'Wednesday'
     WHEN 5 THEN 'Thursday'
     WHEN 6 THEN 'Friday'
     WHEN 7 THEN 'Saturday'
 END AS day_of_week,
 COUNT(CASE
     WHEN cr.start_station_name LIKE ts.keyword_1 AND cr.start_station_name LIKE
ts.keyword_2
      THEN cr.trip_id
 END) AS departures,
 COUNT(CASE
     WHEN cr.end_station_name LIKE ts.keyword_1 AND cr.end_station_name LIKE
ts.keyword_2

    THEN cr.trip_id
 END) AS arrivals,
 COUNT(CASE
   WHEN cr.end_station_name LIKE ts.keyword_1 AND cr.end_station_name LIKE
ts.keyword_2
    THEN cr.trip_id
 END)
 - COUNT(CASE
   WHEN cr.start_station_name LIKE ts.keyword_1 AND cr.start_station_name LIKE
ts.keyword_2
    THEN cr.trip_id
 END) AS net_bike_flow
FROM target_stations ts
JOIN cleaned_rentals cr
 ON (cr.start_station_name LIKE ts.keyword_1 AND cr.start_station_name LIKE
ts.keyword_2)
 OR (cr.end_station_name LIKE ts.keyword_1 AND cr.end_station_name LIKE ts.keyword_2)
GROUP BY ts.station_label, cr.day_number
ORDER BY ts.station_label, cr.day_number;
