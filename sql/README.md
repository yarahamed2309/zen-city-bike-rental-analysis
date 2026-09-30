# SQL queries

Team project by Yara Hamed, Narmeen, and Ahd. Yara focused on station imbalance analysis.

These 17 GoogleSQL queries were extracted from the numbered, English-language section of the submitted SQL PDF. Formatting was cleaned; analytical logic was preserved. Each query can be opened and run separately in BigQuery with access to the referenced tables.

## Start here

- `05_top_5_sources_and_top_5_sinks.sql`: ranks stations by net trip flow.
- `06_full_station_balance_for_map.sql`: station balance and imbalance magnitude.
- `08_top_route_flows.sql`: popular routes.
- `09_route_flows_with_source_sink_context.sql`: routes and station balance.

## Reproducibility and limits

- Requires access to `bqproj-488319.zen_city.rentals`. The project table is not included.
- Query 07 also references the public Austin Bikeshare station table.
- Queries were checked for extraction artifacts, comment closure, and statement endings, but were not executed or validated against live BigQuery data.
- Net trip flow is arrivals minus departures, not actual station inventory.
- Original cleaning rules and query-specific filters are preserved. SELECT DISTINCT removes identical selected rows; it does not guarantee one record per trip ID.
- Timestamp interpretation is preserved from the source and should be checked before drawing conclusions about local peak hours.
- Query 14 is a hypothetical 50% imbalance-reduction scenario, not an observed intervention outcome.
- A separate forecasting appendix in the PDF was omitted because text extraction scrambled its SQL. Query 13 remains the baseline query in the numbered section; this package does not claim to contain the complete final forecast model.
