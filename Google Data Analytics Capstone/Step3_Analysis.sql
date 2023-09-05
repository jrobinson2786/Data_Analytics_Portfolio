------------------------------------------------------------------------------------
------------------------------------Analysis----------------------------------------
------------------------------------------------------------------------------------

------- What is the new total number of rides compared to the old?
SELECT 
  COUNT(ride_id) AS total_rides
FROM cyclistic_capstone.clean_trips; 
-- post-clean total: 5,222,823

------- what is the percentage of casual rides vs the percentage of total rides
WITH total_rides AS(
  SELECT 
    user_type,
    ride_id
  FROM cyclistic_capstone.clean_trips 
)
SELECT 
  user_type,
  COUNT(ride_id) AS rides_by_user, 
  ROUND(COUNT(ride_id) / (SELECT COUNT(ride_id) FROM total_rides)*100, 0) AS percent_by_user
FROM total_rides
GROUP BY user_type;
/*
Where the total number of rides was: 5,222,823
the total number of casual riders was: 2,121,434 or 41% of total riders.
the total number of member riders was: 3,101,389 or 59% of total riders.
*/

------- What is the percentage of docked_type and e_type for casual riders vs. member riders?
WITH member_rides AS(
  SELECT 
    ride_id, 
    user_type, 
    bike_type
  FROM cyclistic_capstone.clean_trips 
  WHERE user_type = 'member'
),
casual_rides AS(
  SELECT 
    ride_id, 
    user_type, 
    bike_type
  FROM cyclistic_capstone.clean_trips 
  WHERE user_type = 'member'
)
SELECT 
  user_type,
  bike_type,
  COUNT(ride_id) AS ride_count,
  ROUND(COUNT(*) / (SELECT COUNT(*) FROM member_rides)*100, 0) AS percentage_breakdown
FROM member_rides
GROUP BY 
  user_type, 
  bike_type
ORDER BY
  ROUND(COUNT(*) / (SELECT COUNT(*) FROM member_rides)*100, 0) DESC
/*
casual riders appear to be indifferent between electric bikes and docked/classic-type bikes while 
members seem to prefer classic/docked bikes over electric
*/

------- what is the annual breakdown of rides per month between casual riders and members? 
WITH total_rides AS(
  SELECT 
    ride_id, 
    month,
    user_type
  FROM cyclistic_capstone.clean_trips
)
SELECT 
  user_type,
  month, 
  SUM(COUNT(ride_id))
    OVER(PARTITION BY user_type) AS ride_count, 
  COUNT(ride_id) AS num_ride_by_month,
  (SELECT COUNT(ride_id) FROM total_rides) AS overall_total_rides,
  ROUND(COUNT(ride_id) / (SELECT COUNT(ride_id) FROM total_rides)*100, 3) AS percent_of_overall_total
FROM total_rides
GROUP BY 
  user_type, 
  month
ORDER BY 
  user_type, 
  ROUND(COUNT(ride_id) / (SELECT COUNT(ride_id) FROM total_rides)*100, 3) DESC;
/*
in general, ridership is higher during the summer months (May-Sep) for both members and casual riders. 
though casual rides are significantly higher during summer months compared to the rest of the year.  
*/


------- What is the breakdown of average ride time by user & type?
WITH ride_time AS(
  SELECT
    user_type, 
    bike_type,
    ride_duration_in_min
  FROM cyclistic_capstone.clean_trips
)
SELECT 
  user_type,
  bike_type,
  ROUND(AVG(ride_duration_in_min), 0) AS avg_time_by_type,
  AVG(AVG(ride_duration_in_min))
    OVER(PARTITION BY user_type ORDER BY user_type) AS avg_by_user_type
FROM ride_time
GROUP BY 
  user_type,
  bike_type
ORDER BY 
  user_type,
  ROUND(AVG(ride_duration_in_min), 0) DESC
/*
both casual riders and member ride classic bikes for longer periods of time. 
*/


------- what is the weekly breakdown of rides per day between casual riders and members?
WITH total_rides AS(
  SELECT 
    ride_id,
    day_of_week, 
    user_type
  FROM cyclistic_capstone.clean_trips 
)
SELECT 
  user_type, 
  day_of_week, 
  SUM(COUNT(ride_id)) 
    OVER(PARTITION BY user_type) AS ride_count,
  COUNT(ride_id) AS num_rides_by_day,
  (SELECT COUNT(ride_id) FROM total_rides) AS overall_total_rides,
  ROUND(COUNT(ride_id) / (SELECT COUNT(ride_id) FROM total_rides)*100, 0) AS percent_of_overall_total
FROM total_rides 
GROUP BY 
  user_type, 
  day_of_week
ORDER BY 
  user_type, 
  ROUND(COUNT(ride_id) / (SELECT COUNT(ride_id) FROM total_rides)*100, 0) DESC;
/*
within the timeline of the data: 
57% of casual rides took place during the weekend Fri-Sun ranked from Sat, Sun, Fri.
--inversely--
61% of member rides took place during the work-week
*/

------- What is the weekly breakdown of average ride times per day compared to total average?
WITH total_rides AS(
  SELECT 
    user_type,
    day_of_week,
    ride_duration_in_min AS ride_time
  FROM cyclistic_capstone.clean_trips 
)
SELECT 
  user_type,
  day_of_week,
  ROUND(AVG(ride_time)) AS avg_ride_time,
  AVG(AVG(ride_time)) 
    OVER(PARTITION BY user_type) AS total_avg_by_user_type
FROM total_rides
GROUP BY 
  day_of_week, 
  user_type
ORDER BY 
  user_type;
/*
total average ride time (approx): 
casual: 23 minutes
member: 13 minutes
both members members and casual riders appear to have above-average ride times on weekends. 
*/

------- time of day (tod)
------- What time of day are to casual riders tend to ride? 
WITH start_time AS(
  SELECT 
    user_type,
    ride_id,
    started_at,
    CASE
      WHEN started_at BETWEEN '17:00:00' AND '23:59:00' THEN 'evening'
      WHEN started_at BETWEEN '00:00:00' AND '03:59:00' THEN 'evening'
      WHEN started_at BETWEEN '04:00:00' AND '11:59:00' THEN 'morning'
      WHEN started_at BETWEEN '12:00:00' AND '16:59:00' THEN 'afternoon'
    END AS time_of_day,
    day_of_week,
    bike_type,
    ride_duration_in_min    
  FROM cyclistic_capstone.clean_trips   
),
rides_at_tod AS(
SELECT 
  user_type,
  time_of_day,
  COUNT(ride_id) AS ride_count,
FROM start_time
GROUP BY 
  time_of_day,
  user_type
ORDER BY 
  user_type, 
  COUNT(ride_id) DESC
)
------- what is the avg ride duration at tod?
SELECT 
  user_type,
  time_of_day,
  AVG(ride_duration_in_min) AS avg_time_at_tod,
  AVG(AVG(ride_duration_in_min))
    OVER(PARTITION BY user_type) AS avg_ride_time_by_type
FROM start_time
GROUP BY 
  time_of_day,
  user_type
ORDER BY 
  user_type, 
  COUNT(ride_id) DESC

/*
where the time of day broken into 3 distnct (and equal) 8-hour timeframes, 
encompassing mornings, afternoons, and evenings. 
more casual riders appear to be riding more in the evenings 
(ie: between the hours of 5pm and 3am)
there is no significant deviation in the average ride times throughout the day. 
*/



------- Which start/end stations are the most common for casual riders? 
WITH start_stations AS(
  SELECT 
    user_type,
    start_station_name, 
    ride_id
  FROM cyclistic_capstone.clean_trips 
)
SELECT 
  user_type,
  DENSE_RANK() 
    OVER(PARTITION BY user_type ORDER BY COUNT(ride_id) DESC) AS station_rank,
  start_station_name,
  COUNT(ride_id) AS ride_count
FROM start_stations
WHERE 
  user_type = 'casual' AND 
  start_station_name IS NOT NULL
GROUP BY 
  user_type,
  start_station_name; 
/*
The top 20 most-used starting locations for casual riders are: 
1. Streeter Dr. & Grand Ave.
2. Dusable Lake Shore Dr. & Monroe St.
3. Millenium Park
4. Michigan Ave & Oak Street
5. Dusable Lake Shore Dr & North Blvd. 
6. Shedd Aquarium
7. Wells St. & Concord
8. Theater on The Lake
9. Dusable Harbor 
10. Clark St. & Armitage Ave. 
11. Indiana Ave & Roosevelt Road
12. Clark St. & Lincoln Ave. 
13. Clark St. & Elm
14. Wells St. & Elm 
15. Montrose Harbor
16. Broadway & Barry Ave. 
17. Clark St. & Newport St. 
18. Wabash Ave & Grand Ave
19. Wilton Ave & Belmont Ave
20. Michigan Ave & 8th St. 
*/

WITH end_stations AS(
  SELECT 
    user_type,
    end_station_name, 
    ride_id
  FROM cyclistic_capstone.clean_trips 
)
SELECT 
  user_type,
  DENSE_RANK() 
    OVER(PARTITION BY user_type ORDER BY COUNT(ride_id) DESC) AS station_rank,
  end_station_name,
  COUNT(ride_id) AS ride_count
FROM end_stations
WHERE 
  user_type = 'casual' AND 
  end_station_name IS NOT NULL
GROUP BY 
  user_type,
  end_station_name 
/*
Top 20 most-common destinations for casual riders are: 
1. Streeter Dr. & Grand Ave
2. DuSable Lake Shore Dr. & Monroe St. 
3. Millenium Park
4. Michigan Ave & Oak St. 
5. Dusable Lake Shore Dr & North Blvd
6. Theater on the Lake
7. Shedd Aquarium
8. Wells St. & Concord Ln
9. Clark St. & Armitage Ave
10. Clark St. & Lincoln Ave 
11. Dusable Harbor
12. Indiana Ave & Roosevelt Rd. 
13. Clark St. & Elm St.
14. Montrose Harbor
15. Wabash Ave & Grand Ave
16. Clark St. & Newport St.
17. Broadway & Barry Ave
18. Sheffield Ave & Waveland Ave
19. Wells St. & Elm st. 
20. Michigan Ave & Washington St
*/
