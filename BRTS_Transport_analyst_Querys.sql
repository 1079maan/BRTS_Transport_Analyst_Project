-- 1. Insert a new passenger feedback for trip_id = 25 with name "Jay Patel" and rating 4.
Update passenger_feedback
SET passenger_name = 'Jay Patel', rating = 4
where "trip_id" = 25

select * from passenger_feedback
order by trip_id


-- 2. Update the driver_name for vehicle_id = 5 to "Rishi Ladani".
Update vehicles
set driver_name = 'Rishi Ladani'
where vehicle_id = 5

select * from vehicles
order by vehicle_id


-- 3. Show all trips delayed more than 5 minutes (delay_sec > 300), ordered by delay descending.
select * from trip_data
where delay_sec > 300
order by delay_sec DESC


-- 4. Count the total number of unique stops across all routes.
SELECT COUNT(DISTINCT stop_id) AS total_unique_stops
FROM route_stops;


-- 5. Find the average passenger rating per route, but show only those routes where avg_rating < 3.5.
with AVG_rat as (
	SELECT TD.route_id, 
		AVG(PF.rating) as avg_rating
	FROM passenger_feedback as PF
	JOIN trip_data AS TD
	ON PF.trip_id = TD.trip_id
	GROUP BY TD.route_id
	ORDER BY TD.route_id
)
SELECT * FROM AVG_rat
WHERE avg_rating > 3


-- 6. List all trips with their route_name, vehicle_type, and driver_name (JOIN route + vehicles + trip_data).
select td.trip_id,
    r.route_name,
    v.vehicle_type,
    v.driver_name,
    td.scheduled_departure,
    td.scheduled_arrival,
    td.actual_departure,
    td.actual_arrival,
    td.delay_sec,
    td.weather_condition
from route as r
JOIN vehicles as v
	ON R.route_id = V.route_id
JOIN trip_data as td
	ON R.route_id = td.route_id


-- 7. Find trips where delay_sec is greater than the average delay of all trips (subquery).
SELECT * FROM trip_data
where delay_sec > (SELECT AVG(delay_sec) FROM trip_data)
ORDER BY delay_sec DESC


-- 8. Rank all vehicles by their average delay using a Window Function (RANK).
SELECT v.vehicle_id, v.vehicle_type, v.driver_name, r.route_name,
	AVG(td.delay_sec) as avg_delay_sec,
	RANK() OVER(order By AVG(td.delay_sec)DESC) as delay_rank
from route as r
JOIN vehicles as v
	ON R.route_id = V.route_id
JOIN trip_data as td
	ON R.route_id = td.route_id
GROUP BY v.vehicle_id, v.vehicle_type, v.driver_name, r.route_name
ORDER BY delay_rank


-- 9. Categorize each trip into Morning, Afternoon, Evening, or Night based on scheduled_departure using a CASE expression.
SELECT *,
    CASE
        WHEN scheduled_departure BETWEEN '06:00:00' AND '11:59:00' THEN 'Morning'
        WHEN scheduled_departure BETWEEN '12:00:00' AND '17:59:00' THEN 'Afternoon'
        WHEN scheduled_departure BETWEEN '18:00:00' AND '21:59:00' THEN 'Evening'
        WHEN scheduled_departure BETWEEN '22:00:00' AND '23:59:00' THEN 'Night'
        ELSE 'Late Night'
    END AS time_slot
FROM trip_data;


-- 10. Create a CTE that calculates the average delay per route, and then select only the top 3 routes with the highest delay.
with avg_delsy AS (
	SELECT r.route_id, r.route_name, AVG(td.delay_sec) as avg_delay_sec
	FROM trip_data as td
	JOIN route as r
	ON td.route_id = r.route_id
	GROUP BY r.route_name, r.route_id
	
)
SELECT * FROM avg_delsy
ORDER BY avg_delay_sec DESC
LIMIT 3


-- 11. Find trips that are faster than scheduled (actual_arrival < scheduled_arrival).
SELECT * FROM trip_data
where actual_arrival < scheduled_arrival
ORDER BY scheduled_arrival


-- 12. Using a Window Function, calculate the running total of trips for each route, ordered by scheduled_departure.
SELECT trip_id,route_id,scheduled_departure,
	COUNT(*) OVER(PARTITION BY route_id ORDER BY scheduled_departure ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as running_total_trips
FROM trip_data
ORDER BY route_id, scheduled_departure


-- 13. Use a CASE expression to classify delay severity:
-- 		0–200 sec → "On Time"
-- 		201–500 sec → "Slight Delay"
--  	501 sec → "Heavy Delay"
SELECT trip_id, delay_sec,
	CASE 
		WHEN delay_sec BETWEEN 0 and 200 THEN 'On Time'
		WHEN delay_sec BETWEEN 201 and 500 THEN 'Slight Delay'
		ELSE 'Heavy Delay'
	END AS delay_severity
FROM trip_data


-- 14. Find the total number of trips for each route using a Window Function (without using GROUP BY).
SELECT DISTINCT 
    td.route_id,
    COUNT(td.route_id) OVER (PARTITION BY td.route_id) AS total_trips_per_route
FROM trip_data td
ORDER BY td.route_id;


-- 15. Find the top 3 vehicles with the highest total delay time across all trips.
SELECT v.vehicle_id, td.route_id,
	SUM(td.delay_sec) as delay_per_route
FROM trip_data as td
JOIN vehicles as v
ON td.route_id = v.route_id
GROUP BY td.route_id, v.vehicle_id
ORDER BY delay_per_route DESC
LIMIT 3 

	
-- 16. For each route, calculate the average trip delay and classify it as Low Delay (<300 sec), Medium Delay (300–600 sec), or High Delay (>600 sec).
with avg_delay_classify as (
	SELECT route_id,
		AVG(delay_sec) as avg_delay
	FROM trip_data
	GROUP BY route_id
	ORDER BY route_id
)
SELECT *, 
case 
	when avg_delay < 300 Then 'Low Delay'
	when avg_delay BETWEEN 300 and 600 Then 'Medium Delay'
	when avg_delay > 600 Then 'High Delay'
END as delay_classify
FROM avg_delay_classify


-- 17. Identify the route with the maximum number of unique stops using route_stops and stops tables.
SELECT rs.route_id, r.route_name,
	COUNT(rs.stop_id) as Unique_stops
FROM route_stops as rs
JOIN route as r
ON rs.route_id = r.route_id
GROUP BY rs.route_id,r.route_name
ORDER BY Unique_stops DESC
LIMIT 1


-- 18. Find the driver(s) whose vehicles have the least average delay across trips.
SELECT 
    v.driver_name,
    ROUND(AVG(td.delay_sec), 2) AS avg_delay_sec
FROM trip_data td
JOIN vehicles v ON td.route_id = v.route_id
GROUP BY v.driver_name
HAVING ROUND(AVG(td.delay_sec), 2) = (
    SELECT MIN(avg_delay)
    FROM (
        SELECT AVG(td2.delay_sec) AS avg_delay
        FROM trip_data td2
        JOIN vehicles v2 ON td2.route_id = v2.route_id
        GROUP BY v2.driver_name
    ) sub
)
ORDER BY v.driver_name;


-- 19. For each time slot (Morning, Afternoon, Evening, Night), find the most delayed route.
SELECT trip_id, delay_sec,
    CASE
        WHEN scheduled_departure BETWEEN '06:00:00' AND '11:59:00' THEN 'Morning'
        WHEN scheduled_departure BETWEEN '12:00:00' AND '17:59:00' THEN 'Afternoon'
        WHEN scheduled_departure BETWEEN '18:00:00' AND '21:59:00' THEN 'Evening'
        WHEN scheduled_departure BETWEEN '22:00:00' AND '23:59:00' THEN 'Night'
        ELSE 'Late Night'
    END AS time_slot
FROM trip_data;


-- 20. List the first and last stop of every route (start → end) using window functions.
SELECT route_id, route_name,
       MAX(CASE WHEN rn_asc = 1 THEN stop_name END) AS first_stop,
       MAX(CASE WHEN rn_desc = 1 THEN stop_name END) AS last_stop
FROM (
    SELECT r.route_id, r.route_name, s.stop_name,
           ROW_NUMBER() OVER (PARTITION BY r.route_id ORDER BY rs.stop_sequence ASC)  AS rn_asc,
           ROW_NUMBER() OVER (PARTITION BY r.route_id ORDER BY rs.stop_sequence DESC) AS rn_desc
    FROM route r
    JOIN route_stops rs ON r.route_id = rs.route_id
    JOIN stops s ON rs.stop_id = s.stop_id
) sub
GROUP BY route_id, route_name
ORDER BY route_id;


-- 21. Identify the routes where more than 40% of trips are delayed (delay_sec > 0).
SELECT 
	td.route_id,
	r.route_name,
	COUNT(*) as total_trip,
	COUNT(case when td.delay_sec > 0 then 1 end) AS delay_trips,
	ROUND(
		COUNT(case when td.delay_sec > 0 then 1 end) * 100.0 / COUNT(*),2
	) as delay_percentage
FROM trip_data as td
JOIN route as r 
ON td.route_id = r.route_id
group by td.route_id, r.route_name


-- 22: Full stop sequence for route_id = 5 → table: “Q8_Full_Path_for_route_5”
select rs.route_id, rs.route_name, s.stop_id, s.stop_name
FROM route_stops as rs
JOIN stops as s
ON rs.stop_id = s.stop_id
where rs.route_id = 5
order by stop_id


-- 23: Top 5 passengers with lowest avg ratings → table: “Q9_Top5_Passengers_Lowest_Avg_Ratings”
select passenger_name, 
	ROUND (AVG(rating),2) as avg_rating
from passenger_feedback
group by passenger_name
ORDER by avg_rating ASC
LIMIT 5


-- 24. Find the top 3 routes with the highest average delay per trip
SELECT r.route_name, ROUND(AVG(td.delay_sec),2)
from trip_data as td 
join route as r 
ON td.route_id = r.route_id
group by r.route_name
ORDER BY AVG(td.delay_sec) DESC
LIMIT 3


-- 25. For each driver, calculate the percentage of trips where the delay exceeded 10 minutes (600 sec).
SELECT v.driver_name,
	ROUND(COUNT(CASE WHEN td.delay_sec > 600 THEN 1 END)::decimal / COUNT(*) * 100,2) AS percent_trips_delayed
FROM vehicles as v
JOIN route as r ON v.route_id = r.route_id
JOIN trip_data as td ON td.route_id = r.route_id
GROUP BY v.driver_name


-- 26. Identify the stop that is part of the maximum number of different routes.
SELECT 
    s.stop_id,
    s.stop_name,
    COUNT(DISTINCT rs.route_id) route_count
FROM route_stops rs
JOIN stops s ON rs.stop_id = s.stop_id
group by s.stop_id, s.stop_name
ORDER BY route_count DESC
LIMIT 1


-- 27. Find the passengers who always gave the same rating (never changed their rating).
SELECT passenger_name,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	count(*) as feedback_count
FROM passenger_feedback
where rating is not null
group by passenger_name
HAVING MIN(rating) = MAX(rating)
ORDER BY feedback_count DESC


-- 28. Find the top 5 trips with the worst delay-to-rating ratio (delay_sec divided by passenger rating).
SELECT td.trip_id, pf.passenger_name, pf.rating, td.delay_sec,
	(td.delay_sec/pf.rating) as delay_to_rating_ratio
FROM trip_data as td
JOIN passenger_feedback as pf
ON td.trip_id = pf.trip_id
ORDER BY delay_to_rating_ratio DESC
LIMIT 5
