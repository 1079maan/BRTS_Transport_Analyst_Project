-- Beginner → Intermediate Tasks

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


-- Intermediate → Advanced Tasks

-- 1. List all trips with their route_name, vehicle_type, and driver_name (JOIN route + vehicles + trip_data).
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

-- 2. Find trips where delay_sec is greater than the average delay of all trips (subquery).
SELECT * FROM trip_data
where delay_sec > (SELECT AVG(delay_sec) FROM trip_data)
ORDER BY delay_sec DESC

-- 3. Rank all vehicles by their average delay using a Window Function (RANK).
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

-- 4. Categorize each trip into Morning, Afternoon, Evening, or Night based on scheduled_departure using a CASE expression.
SELECT *,
    CASE
        WHEN scheduled_departure BETWEEN '06:00:00' AND '11:59:00' THEN 'Morning'
        WHEN scheduled_departure BETWEEN '12:00:00' AND '17:59:00' THEN 'Afternoon'
        WHEN scheduled_departure BETWEEN '18:00:00' AND '21:59:00' THEN 'Evening'
        WHEN scheduled_departure BETWEEN '22:00:00' AND '23:59:00' THEN 'Night'
        ELSE 'Late Night'
    END AS time_slot
FROM trip_data;

-- 5. Create a CTE that calculates the average delay per route, and then select only the top 3 routes with the highest delay.
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