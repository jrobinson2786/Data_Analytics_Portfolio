CREATE TABLE cyclistic_capstone.clean_trips AS(
-- Step 1. exclude items that are universally unwanted
WITH initial_exclusions AS(
  SELECT * 
  FROM cyclistic_capstone.trips_compl 
  WHERE
    start_station_name <> 'Base - 2132 W Hubbard' OR
    start_station_name <> 'Base - 2132 W Hubbard Warehouse' OR        
    start_station_name <> 'DIVVY CASSETTE REPAIR MOBILE STATION' OR   
    end_station_name <> 'Base - 2132 W Hubbard' OR                    
    end_station_name <> 'Base - 2132 W Hubbard Warehouse' OR
    end_station_name <> 'DIVVY CASSETTE REPAIR MOBILE STATION' OR
    start_station_id <> 'DIVVY 001 - Warehouse test station' OR
    end_station_id <> 'DIVVY 001 - Warehouse test station'
),
-- Step 2. isolate null values to be excluded
excluded_nulls AS(
    SELECT ride_id AS null_id
    FROM (SELECT 
          ride_id, 
          start_station_name, 
          start_station_id, 
          end_station_name, 
          end_station_id
        FROM initial_exclusions  
        WHERE rideable_type = 'docked_bike' OR 
        rideable_type = 'classic_bike'
        )
    WHERE 
      start_station_name IS NULL AND 
      start_station_id IS NULL OR
      end_station_name IS NULL AND 
      end_station_id IS NULL
),
-- Step 3. reintegrate cleaned NULL values.
recombined_data AS(
   SELECT *
   FROM initial_exclusions ie
   LEFT JOIN excluded_nulls en
   ON ie.ride_id = en.null_id 
   WHERE en.null_id IS NULL
)
-- Step 4. final data transformation. 
  SELECT 
    ride_id, 
    rideable_type AS bike_type,
    CAST(started_at AS date) AS date,
    CAST(started_at AS time) AS started_at,
    CAST(ended_at AS time) AS ended_at,
    TIMESTAMP_DIFF(ended_at, started_at, MINUTE) AS ride_duration_in_min,
    CASE
      WHEN EXTRACT(MONTH FROM started_at) = 1 THEN 'Jan'
      WHEN EXTRACT(MONTH FROM started_at) = 2 THEN 'Feb'
      WHEN EXTRACT(MONTH FROM started_at) = 3 THEN 'Mar'
      WHEN EXTRACT(MONTH FROM started_at) = 4 THEN 'Apr'
      WHEN EXTRACT(MONTH FROM started_at) = 5 THEN 'May'
      WHEN EXTRACT(MONTH FROM started_at) = 6 THEN 'Jun'
      WHEN EXTRACT(MONTH FROM started_at) = 7 THEN 'Jul'
      WHEN EXTRACT(MONTH FROM started_at) = 8 THEN 'Aug'
      WHEN EXTRACT(MONTH FROM started_at) = 9 THEN 'Sep'
      WHEN EXTRACT(MONTH FROM started_at) = 10 THEN 'Oct'
      WHEN EXTRACT(MONTH FROM started_at) = 11 THEN 'Nov'
      WHEN EXTRACT(MONTH FROM started_at) = 12 THEN 'Dec'
      END AS month,
    CASE 
      WHEN day_of_the_week = 1 THEN 'Sun'
      WHEN day_of_the_week = 2 THEN 'Mon'
      WHEN day_of_the_week = 3 THEN 'Tue'
      WHEN day_of_the_week = 4 THEN 'Wed'
      WHEN day_of_the_week = 5 THEN 'Thu'
      WHEN day_of_the_week = 6 THEN 'Fri'
      WHEN day_of_the_week = 7 THEN 'Sat'
      END AS day_of_week,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    start_lat, 
    start_lng,
    end_lat,
    end_lng,
    member_casual AS user_type
FROM recombined_data 
WHERE 
  TIMESTAMP_DIFF(ended_at, started_at, MINUTE) BETWEEN 1 AND 1440
)
