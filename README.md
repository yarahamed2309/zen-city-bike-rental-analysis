
# Zen City Bike Rental Analysis

An analysis of Austin bike rental data from Q1 2022, exploring station imbalances, rental patterns, and opportunities to support rental growth in Q2.

## Business Objective

Identify stations with high net departures or arrivals and recommend targeted bike redistribution to improve availability across the network.

## Tools

- SQL and Google BigQuery
- Python
- Google Sheets

## Analysis Approach

- Cleaned and standardized rental data.
- Analyzed demand by month, day, and hour.
- Examined popular routes and station relationships.
- Calculated station net flow to identify bike accumulation and shortage risks.
- Developed recommendations for rebalancing and a rental forecast for April 1, 2022.

## Station Imbalance Analysis

Station net flow was calculated as:

**Net flow = arriving trips − departing trips**

Positive values indicate more arrivals than departures; negative values indicate more departures than arrivals.

### Key Findings

- **PCL @ 21st & Speedway:** net flow of **+3,552**, indicating substantial net bike inflow.
- **Dean Keeton/Speedway:** net flow of **−1,852**, indicating substantial net bike outflow.
- Three leading routes into PCL accounted for **2,126 trips**, highlighting concentrated demand toward this destination.

These patterns suggest priority locations for bike redistribution. Net trip flow indicates imbalance risk; it does not directly measure real-time bike inventory or confirm when stations were empty or full.

## Business Recommendations

- Prioritize redistribution from stations with high net inflow to stations with high net outflow.
- Align rebalancing schedules with observed peak demand.
- Monitor bike availability and docking capacity to evaluate whether interventions improve service.
- Track rental volume in Q2 to assess progress toward the growth objective.

## Team and My Contribution

This project was completed collaboratively by **Yara Hamed, Narmeen, and Ahd**.

We worked together across the project. My primary focus was **station imbalance analysis**, examining net bike flows and identifying stations to prioritize for rebalancing.

## Project Context

Zen City is an educational case study using bike rental data for Austin, Texas. Recommendations are proposed actions, rather than measured results from an implemented intervention.
