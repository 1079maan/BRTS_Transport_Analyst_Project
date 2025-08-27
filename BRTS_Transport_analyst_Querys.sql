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
SELECT TD.route_id, 
	AVG(PF.rating) OVER(PARTITION BY TD.route_id ORDER BY TD.route_id) as avg_rating
FROM passenger_feedback as PF
JOIN trip_data AS TD
ON PF.trip_id = TD.trip_id
where avg_rating < 3


SELECT * from trip_data
