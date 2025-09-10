# 🚍 Ahmedabad BRTS Transport Analyst Project

## 📌 Project Overview
The Ahmedabad BRTS (Bus Rapid Transit System) generates large volumes of operational data such as routes, trips, vehicles, stops, delays, and passenger feedback.  
This project transforms raw BRTS data into **actionable transport insights** using **PostgreSQL + SQL + Power BI**.

✅ Goals:
- Analyze bus delays and punctuality.
- Measure passenger satisfaction via feedback ratings.
- Identify top/bottom performing routes and drivers.
- Build an **interactive Power BI dashboard** for transport analysts and city planners.

---

## 🛑 Problem Statement
Raw operational data from the BRTS system is not enough to make informed decisions.  
We need a system to:
- Track **bus delays** and punctuality.
- Monitor **driver & vehicle performance**.
- Understand **passenger satisfaction**.
- Provide a **visual, data-driven dashboard** for city transport planning.

---

## 🗂 Data Collection
- Data scraped from the **official Ahmedabad BRTS site** using **Python + Selenium**.
- Stored in **CSV files**:
  - `brts_routes.csv` → Route details
  - `brts_stops.csv` → Stops with lat/long
  - `brts_route_stops.csv` → Route-Stop mappings
  - `brts_trip_data.csv` → Trip schedules, actuals, delays
  - `brts_passenger_feedback.csv` → Passenger ratings
  - `brts_vehicles.csv` → Vehicles and drivers
- Enriched stop data with **Geopy (lat/long)**.
- Added simulated **trip delays, weather conditions, passenger feedback**.

---

## 🛢 Database Design (PostgreSQL)
A **normalized schema** was designed:

- **routes** (route_id, route_name, start_stop, end_stop)  
- **stops** (stop_id, stop_name, latitude, longitude)  
- **route_stops** (route_id, stop_id, stop_sequence)  
- **vehicles** (vehicle_id, route_id, vehicle_type, driver_name, driver_license)  
- **trip_data** (trip_id, route_id, scheduled_departure, scheduled_arrival, actual_departure, actual_arrival, delay_sec, weather_condition, time_slot)  
- **passenger_feedback** (feedback_id, trip_id, passenger_name, rating)

Highlights:
- **Bridge Table**: `route_stops` handles many-to-many routes ↔ stops.  
- **Foreign Keys** maintain integrity.  
- **Time Slots** derived for analysis (Morning, Afternoon, Evening, Night).  

---

## 📝 SQL Queries (28 Final Queries)
We wrote **28 queries** categorized into levels:

### 🟢 Beginner
- Insert passenger feedback.  
- Update driver name.  
- Trips delayed >5 minutes.  
- Count unique stops.  
- Avg rating per route (<3.5).  

### 🟡 Intermediate
- Joins (routes + vehicles + trips).  
- Subquery: delay > avg delay.  
- Rank vehicles by delay.  
- CASE: trip time slots.  
- CTE: avg delay per route (top 3).  
- Delay severity classification.  
- % delayed trips per route.  
- Driver performance (% trips >10 mins delay).  

### 🔴 Advanced
- Running totals of trips (Window).  
- Trips faster than schedule.  
- Recursive CTE: full stop sequence.  
- Top delayed vehicles.  
- First/Last stop per route.  
- Worst delay-to-rating trips.  
- Top 5 passengers (lowest avg rating).  

---

## 📊 Power BI Dashboard
A **multi-page dashboard** was created:

### 1️⃣ Overview
- KPIs (Total Trips, Avg Delay, % Delayed, Avg Rating)  
- City Map (routes + stops)  
- Delay Trend (by time of day)  
- Top 3 Delayed Routes  

### 2️⃣ Route Performance
- Table (Route Name, Trips, Avg Delay, Avg Rating, Stops)  
- Bar Chart (Routes ranked by delay)  
- Heatmap (Delay by time slot)  
- Highlight Card (Route with Max Stops)  

### 3️⃣ Trip Analytics
- Delay Severity Distribution  
- Running Total Trips (line chart)  
- Top 5 Worst Delay-to-Rating Trips  
- % Faster Trips KPI  

### 4️⃣ Driver & Vehicle Performance
- Driver Performance Table  
- Vehicle Rankings (delay-based)  
- Delay Distribution by Vehicle Type  
- Best Performing Driver card  

### 5️⃣ Passenger Feedback
- Table (Passenger, Avg Rating, Feedback Count)  
- Top 5 Worst Ratings  
- Delay vs Rating Scatter Plot  
- Consistent Ratings KPI  

---

## ⚙️ Tech Stack
- **Data Collection**: Python (Selenium, Pandas, Geopy)  
- **Database**: PostgreSQL  
- **Analysis**: SQL (CTEs, Window Functions, Subqueries)  
- **Visualization**: Power BI  

---

## 🎯 Project Outcomes
- Built a **normalized database** for BRTS operations.  
- Developed **28 SQL queries** (CRUD → advanced analytics).  
- Designed a **modular Power BI dashboard** for transport decision-making.  
- Created a **scalable framework** that can be extended to real-time monitoring.  

---

## 🚀 How to Run
1. Clone the repository:  
   ```bash
   git clone https://github.com/1079maan/BRTS_Transport_Analyst_Project.git
