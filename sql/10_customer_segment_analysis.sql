-- GoogleSQL (BigQuery). Extracted from the team SQL PDF.
-- Requires access to the original project tables; results have not been rerun.

/* ============================================================================
    10_CUSTOMER_SEGMENT_ANALYSIS
    Purpose:
    Compare rental volume and usage by customer/subscriber segment.
    This supports customer behavior and profitability discussion.
============================================================================ */

WITH cleaned_rentals AS (
 SELECT DISTINCT
     r.trip_id,

     COALESCE(INITCAP(TRIM(r.subscriber_type)), 'Casual Rider') AS customer_segment,
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
 customer_segment,
 COUNT(trip_id) AS total_rentals,
 SUM(duration_minutes) AS total_minutes_utilized,
 ROUND(AVG(duration_minutes), 1) AS avg_ride_duration_minutes,
 ROUND(COUNT(trip_id) * 100.0 / SUM(COUNT(trip_id)) OVER(), 2) AS
share_of_total_rentals
FROM cleaned_rentals
GROUP BY customer_segment
ORDER BY total_rentals DESC;
