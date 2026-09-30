-- GoogleSQL (BigQuery). Extracted from the team SQL PDF.
-- Requires access to the original project tables; results have not been rerun.

/* ============================================================================
  13_FRIDAY_BASELINE_FORECAST
  Purpose:
  Forecast expected station flow for a Friday based on Q1 Friday behavior.
  This supports the April 1 / Q2 opening baseline slide.

  Note:
  Q1 has approximately 12 Fridays, so counts are divided by 12 to estimate
  an average Friday baseline.
============================================================================ */

WITH cleaned_rentals AS (
 SELECT DISTINCT
     trip_id,
     COALESCE(TRIM(start_station_name), 'Unknown Station') AS start_station_name,
     COALESCE(TRIM(end_station_name), 'Unknown Station') AS end_station_name,
     CAST(start_time AS TIMESTAMP) AS start_time,
     COALESCE(INITCAP(TRIM(subscriber_type)), 'Casual Rider') AS subscriber_type,
     CAST(duration_minutes AS INT64) AS duration_minutes
 FROM `bqproj-488319.zen_city.rentals`
 WHERE
     CAST(duration_minutes AS INT64) >= 2
     AND CAST(duration_minutes AS INT64) <= 1440
     AND CAST(start_time AS TIMESTAMP) >= '2022-01-01 00:00:00'
     AND CAST(start_time AS TIMESTAMP) < '2022-04-01 00:00:00'
     AND trip_id IS NOT NULL
),

enriched_rentals AS (
 SELECT
     *,
     EXTRACT(DAYOFWEEK FROM start_time) AS day_of_week
 FROM cleaned_rentals
),
friday_traffic AS (
 SELECT
     start_station_name AS station_name,
     subscriber_type,
     1 AS is_departure,
     0 AS is_arrival
 FROM enriched_rentals
 WHERE day_of_week = 6

 UNION ALL

 SELECT
     end_station_name AS station_name,
     subscriber_type,
     0 AS is_departure,
     1 AS is_arrival
 FROM enriched_rentals
 WHERE day_of_week = 6
),
friday_baseline AS (
 SELECT
     station_name,
     subscriber_type,
     ROUND(SUM(is_departure) / 12.0, 1) AS expected_departures,
     ROUND(SUM(is_arrival) / 12.0, 1) AS expected_arrivals,
     ROUND((SUM(is_arrival) - SUM(is_departure)) / 12.0, 1) AS predicted_net_flow
 FROM friday_traffic
 WHERE station_name != 'Unknown Station'
 GROUP BY station_name, subscriber_type
),
ranked_flow AS (
 SELECT
     *,
     ROW_NUMBER() OVER (ORDER BY predicted_net_flow DESC) AS positive_rank,
     ROW_NUMBER() OVER (ORDER BY predicted_net_flow ASC) AS negative_rank
 FROM friday_baseline

)
SELECT
 'Baseline - Positive (Overcrowded)' AS scenario,
 station_name,
 subscriber_type,
 expected_departures,
 expected_arrivals,
 predicted_net_flow
FROM ranked_flow
WHERE positive_rank <= 5

UNION ALL

SELECT
 'Baseline - Negative (Emptying)' AS scenario,
 station_name,
 subscriber_type,
 expected_departures,
 expected_arrivals,
 predicted_net_flow
FROM ranked_flow
WHERE negative_rank <= 5
ORDER BY scenario DESC, ABS(predicted_net_flow) DESC;
