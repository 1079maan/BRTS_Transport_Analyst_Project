	-- Create Table --
CREATE TABLE route (
    route_id SERIAL PRIMARY KEY,
    route_name VARCHAR(100) NOT NULL,
    start_stop VARCHAR(100) NOT NULL,
    end_stop VARCHAR(100) NOT NULL
);

SELECT * FROM route
drop table route


CREATE TABLE vehicles (
	vehicle_id SERIAL PRIMARY KEY, 
	route_id INT, 
	vehicle_type VARCHAR(100) NOT NULL, 
	driver_name VARCHAR(100) NOT NULL, 
	driver_license VARCHAR(50) UNIQUE NOT NULL,
	FOREIGN KEY (route_id) REFERENCES route(route_id) ON DELETE CASCADE
);

SELECT * FROM vehicles
drop table vehicles


CREATE TABLE stops (
    stop_id SERIAL PRIMARY KEY,
    stop_name VARCHAR(150) NOT NULL,
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6)
);

SELECT * FROM stops
drop table stops


CREATE TABLE route_stops (
    route_id INT NOT NULL,
    stop_id INT NOT NULL PRIMARY KEY,
    stop_sequence INT NOT NULL,
	route_name VARCHAR(100) NOT NULL,
    FOREIGN KEY (route_id) REFERENCES route(route_id) ON DELETE CASCADE,
    FOREIGN KEY (stop_id) REFERENCES stops(stop_id) ON DELETE CASCADE
)

SELECT * FROM route_stops
drop table route_stops


CREATE TABLE trip_data (
    trip_id SERIAL PRIMARY KEY,
    route_id INT NOT NULL,
    scheduled_departure TIME NOT NULL,
    scheduled_arrival TIME NOT NULL,
    actual_departure TIME,
    actual_arrival TIME,
    delay_sec INT,
    weather_condition VARCHAR(50),
	Time_slot VARCHAR(50),
    FOREIGN KEY (route_id) REFERENCES route(route_id) ON DELETE CASCADE
);

SELECT * FROM trip_data
drop table trip_data

CREATE TABLE passenger_feedback ( 
feedback_id SERIAL PRIMARY KEY, 
trip_id INT NOT NULL, 
passenger_name VARCHAR(100), 
rating INT CHECK (rating BETWEEN 1 AND 5), 
FOREIGN KEY (trip_id) REFERENCES trip_data(trip_id) ON DELETE CASCADE 
);

SELECT * FROM passenger_feedback
drop table passenger_feedback

	--INSERT Data --
-- Insert Route data
COPY route(route_name, start_stop, end_stop)
FROM 'I:\SQL\Transport Delay Project\BRTS_Transport\brts_routes_cleaning.csv'
DELIMITER ','
CSV HEADER;


-- Download the all route data.
COPY route TO 'I:\SQL\Transport Delay Project\BRTS_Transport\Final_brts_routes.csv'
DELIMITER ',' 
CSV HEADER;

SELECT * FROM route


-- Insert the vehicle data
COPY vehicles(route_id, vehicle_type, driver_name, driver_license)
FROM 'I:\SQL\Transport Delay Project\BRTS_Transport\BRTS_Vehicle.csv'
DELIMITER ','
CSV HEADER;

-- download the all vehicles data
COPY vehicles TO 'I:\SQL\Transport Delay Project\BRTS_Transport\Final_brts_vehicles.csv'
DELIMITER ',' 
CSV HEADER;

SELECT * FROM vehicles


-- Insert stops data.
COPY stops(stop_name, latitude, longitude)
FROM 'I:\SQL\Transport Delay Project\BRTS_Transport\BRTS_all_stops.csv'
DELIMITER ','
CSV HEADER;

-- download the all stops data
COPY stops TO 'I:\SQL\Transport Delay Project\BRTS_Transport\Final_brts_stops.csv'
DELIMITER ',' 
CSV HEADER;

select * from stops

-- Insert reoute_stops table.
COPY route_stops(route_id, stop_id, stop_sequence, route_name)
FROM 'I:\SQL\Transport Delay Project\BRTS_Transport\Final_brts_route_stops.csv'
DELIMITER ','
CSV HEADER;

select * from route_stops


-- Insert trip_data
COPY trip_data(route_id, scheduled_departure, scheduled_arrival, actual_departure, actual_arrival, delay_sec, weather_condition, Time_slot)
FROM 'I:\SQL\Transport Delay Project\BRTS_Transport\trip_data_time_only.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM trip_data

-- download the trip_data table.
COPY trip_data TO 'I:\SQL\Transport Delay Project\BRTS_Transport\Final_brts_trip_data.csv'
DELIMITER ',' 
CSV HEADER;

select * from trip_data


-- This is optional use of find the time_slot data.
SELECT *,
    CASE
        WHEN scheduled_departure::time BETWEEN '06:00:00' AND '11:59:00' THEN 'Morning'
        WHEN scheduled_departure::time BETWEEN '12:00:00' AND '17:59:00' THEN 'Afternoon'
        WHEN scheduled_departure::time BETWEEN '18:00:00' AND '21:59:00' THEN 'Evening'
        WHEN scheduled_departure::time BETWEEN '22:00:00' AND '23:59:00' THEN 'Night'
        ELSE 'Late Night'
    END AS time_slot
FROM trip_data;


-- INSERT passenger_feedback data.
copy passenger_feedback(trip_id, passenger_name, rating)
FROM 'I:\SQL\Transport Delay Project\BRTS_Transport\passenger_feedback.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM passenger_feedback

-- Download the passenger_feedback data.
copy passenger_feedback TO 'I:\SQL\Transport Delay Project\BRTS_Transport\Final_brts_passenger_feedback.csv'
DELIMITER ','
CSV HEADER;




-- Fix the NUll Values from stop table.
WITH filled AS (
    SELECT
        rs.route_id,
        rs.stop_id,
        rs.stop_sequence,
        COALESCE(s.latitude,
                 LAG(s.latitude) OVER (PARTITION BY rs.route_id ORDER BY rs.stop_sequence),
                 LEAD(s.latitude) OVER (PARTITION BY rs.route_id ORDER BY rs.stop_sequence)) AS new_latitude,
        COALESCE(s.longitude,
                 LAG(s.longitude) OVER (PARTITION BY rs.route_id ORDER BY rs.stop_sequence),
                 LEAD(s.longitude) OVER (PARTITION BY rs.route_id ORDER BY rs.stop_sequence)) AS new_longitude
    FROM stops s
    JOIN route_stops rs ON s.stop_id = rs.stop_id
)
UPDATE stops t
SET latitude  = f.new_latitude,
    longitude = f.new_longitude
FROM filled f
WHERE t.stop_id = f.stop_id
  AND (t.latitude IS NULL OR t.longitude IS NULL);


SELECT * FROM stops
order By stop_id