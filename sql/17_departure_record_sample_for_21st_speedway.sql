-- GoogleSQL (BigQuery). Extracted from the team SQL PDF.
-- Requires access to the original project tables; results have not been rerun.

/* ============================================================================
    17_DEPARTURE_RECORD_SAMPLE_FOR_21ST_SPEEDWAY
    Purpose:
    Diagnostic query only.
    Use this when you want to inspect raw departure records for 21st/Speedway.
    This is not usually needed in the final presentation.
============================================================================ */

SELECT
 trip_id,
 start_station_id,
 start_station_name,
 end_station_id,
 end_station_name,
 CAST(start_time AS TIMESTAMP) AS start_time,
 CAST(duration_minutes AS INT64) AS duration_minutes,
 subscriber_type
FROM `bqproj-488319.zen_city.rentals`
WHERE
 start_station_name LIKE '%21st%'
 AND start_station_name LIKE '%Speedway%'
 AND CAST(start_time AS TIMESTAMP) >= '2022-01-01 00:00:00'
 AND CAST(start_time AS TIMESTAMP) < '2022-04-01 00:00:00'
 AND CAST(duration_minutes AS INT64) >= 2

 AND CAST(duration_minutes AS INT64) <= 1440
ORDER BY start_time ASC
LIMIT 100;
