-----------------------------------------------------------------------
---------------------Create Rough Master Table-------------------------
-----------------------------------------------------------------------
 
CREATE TABLE cyclistic_capstone.trips_compl
AS
(
  SELECT * 
  FROM cyclistic_capstone.cyclistic_202111
  UNION ALL 
 
  SELECT * 
  FROM cyclistic_capstone.cyclistic_202112
  UNION ALL 
 
  SELECT * 
  FROM cyclistic_capstone.cyclistic_202201
  UNION ALL 
 
  SELECT * 
  FROM cyclistic_capstone.cyclistic_202202
  UNION ALL 
 
  SELECT * 
  FROM cyclistic_capstone.cyclistic_202203
  UNION ALL 
 
  SELECT * 
  FROM cyclistic_capstone.cyclistic_202204
  UNION ALL 
 
  SELECT * 
  FROM cyclistic_capstone.cyclistic_202205
  UNION ALL 
 
  SELECT * 
  FROM cyclistic_capstone.cyclistic_202206
  UNION ALL 
 
  SELECT * 
  FROM cyclistic_capstone.cyclistic_202207
  UNION ALL 
 
  SELECT * 
  FROM cyclistic_capstone.cyclistic_202208
  UNION ALL 
 
  SELECT * 
  FROM cyclistic_capstone.cyclistic_202209
  UNION ALL 
 
  SELECT * 
  FROM cyclistic_capstone.cyclistic_202210
);
 
 
-----------------------------------------------------------------------
------------------------Initial Exploration----------------------------
-----------------------------------------------------------------------
 
------- initial count for comparison
SELECT COUNT(*) AS total_count
FROM cyclistic_capstone.trips_compl

--Total count: 5755694
 

------- inspect ride_id column
SELECT 
  LENGTH(ride_id) AS ride_length,
  COUNT(*) AS length_count
FROM cyclistic_capstone.trips_compl
GROUP BY 
  LENGTH(ride_id)
 
/*
- l = 16 : 5751844
- l < 16 : 3850

around the beginning of 2022, the ride_ids began to appear in 
scientific notation. no cleaning will be necessary
*/
 
------- inspect rideable type and member/casual
SELECT
  COUNT(DISTINCT rideable_type) AS bike_types
FROM cyclistic_capstone.trips_compl
 
SELECT 
  COUNT(DISTINCT member_casual) AS script_types
FROM cyclistic_capstone.trips_compl
 
/*
NOTE: 
the query indicates 3 distinct rideable types and 2 distinct subscription types, 
as indicated in the given information. This serves to confirm that there are no
alternate spellings of either column. 
*/
 
 
------- inspect start/end station names 
SELECT 
  start_station_name,
  COUNT(ride_id) AS station_count
FROM cyclistic_capstone.trips_compl
GROUP BY start_station_name
ORDER BY start_station_name
 
SELECT DISTINCT 
  end_station_name,
  COUNT(ride_id) AS station_count
FROM cyclistic_capstone.trips_compl
GROUP BY end_station_name
ORDER BY end_station_name
 
/*
NOTE: 
This was a quick skim for anything that stuck out too badly. I came across the 
following start/end station names to be disregarded in cleaning:
Base - 2132 W Hubbard
Base - 2132 W Hubbard Warehouse
DIVVY CASSETTE REPAIR MOBILE STATION
 
And the following start/end station id:
DIVVY 001 - Warehouse test station
*/
 
------- count/inspect NULL values
SELECT COUNT(*) AS NULL_count
FROM cyclistic_capstone.trips_compl
WHERE 
  start_station_name IS NULL OR end_station_name IS NULL OR
  start_station_id IS NULL OR end_station_id IS NULL OR
  start_lat IS NULL OR end_lat IS NULL OR
  start_lng IS NULL OR end_lng IS NULL
 
-- Total Count: 1345256
 
 
SELECT 
  ride_id, 
  rideable_type,
  start_station_name,
  end_station_name,
  start_station_id,
  end_station_id,
  start_lat,end_lat,
  start_lng, end_lng
FROM cyclistic_capstone.trips_compl
WHERE 
  start_station_name IS NULL OR end_station_name IS NULL OR
  start_station_id IS NULL OR end_station_id IS NULL OR
  start_lat IS NULL OR end_lat IS NULL OR
  start_lng IS NULL OR end_lng IS NULL
 
/*
Seems as though there are a significant amount of NULL values that 
are associated with electric bikes, so I will modify/rerun 
the previous *count* query. 
*/
 
SELECT
  rideable_type,
  COUNT(ride_id) AS NULL_count
FROM cyclistic_capstone.trips_compl
WHERE 
  start_station_name IS NULL OR end_station_name IS NULL OR
  start_station_id IS NULL OR end_station_id IS NULL OR
  start_lat IS NULL OR end_lat IS NULL OR
  start_lng IS NULL OR end_lng IS NULL
GROUP BY rideable_type
ORDER BY rideable_type
 
/*
Majority of NULLs are associated with electric bike. 
This makes sense because electric bikes will not always have a docking station,
Although this was not explained in the given information.
*/
 
-- Cleaning Note: disregard NULLs that are associated with classic/docked bikes ONLY 
 
------- Check timestamps
SELECT 
  COUNT(*) AS bad_timestamp
FROM cyclistic_capstone.trips_compl
WHERE 
  TIMESTAMP_DIFF(ended_at, started_at, MINUTE) < 1
 
SELECT
  COUNT(*) AS bad_timestamp
FROM cyclistic_capstone.trips_compl
WHERE 
  TIMESTAMP_DIFF(ended_at, started_at, MINUTE) > 1440
 
/*
NOTE: 
For the purpose of this project, I'm not interested 
in ride durations that are t < 1 or t > 1440 (1-day)
These are likely recording or operator errors
- t < 1 : 69747
- t > 1440 : 5363
*/
 
/*
Final Cleaning List:
- disregard rows with start/end station names are
  for maintenance. 
- disregard rows with NULL values *UNLESS* they are 
  associated with electric bikes
- disregard rows with bad timestamps
*/
