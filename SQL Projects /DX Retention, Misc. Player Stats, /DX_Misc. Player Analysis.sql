
----- DX Retention Analysis

/*
NOTES: 
1. For the purpose of the dx analysis, the timestamp in "player_deaths" will be used as the "player_login"
After this first analysis, the timestamp ACTUALLY represents player deaths. 
2. DX analysis typically focuses on: D0, D1, D7, D14, D30; 
however, I switched the days to work within the confines of the dataset. 
*/

WITH baseline AS (
	SELECT 
		user_id AS player, 
		DATE(time_death) AS date
	FROM player_deaths
),
start_date AS (
	SELECT 
		MIN(date) AS day_0
	FROM baseline
),
retention AS (
	SELECT 
		player, 	
		CASE 
			WHEN date = (SELECT day_0 FROM start_date) THEN 'D00'
			WHEN date = (SELECT day_0 FROM start_date) + INTERVAL '1 DAY' THEN 'D01' 
			WHEN date = (SELECT day_0 FROM start_date) + INTERVAL '6 DAY' THEN 'D06'
			WHEN date = (SELECT day_0 FROM start_date) + INTERVAL '12 DAY' THEN 'D11'
		END AS dx_segment
	FROM baseline
)
SELECT
	dx_segment,
	COUNT(player),
	ROUND(COUNT(player) / (SELECT COUNT(user_id)::numeric FROM player_deaths)*100, 2) AS "DX_%"
FROM retention  
WHERE dx_segment IS NOT NULL
GROUP BY dx_segment
ORDER BY dx_segment

/*
dx_segment | count  |   DX_%  |
-----------+--------+---------+
       D00 |      1 |    2.50 |
       D01 |      1 |    2.50 |
       D06 |      3 |    7.50 |
       D11 |     18 |   45.00 | 
-----------+--------+---------+

NOTE: 
The curve described above is an upward trend whch indicates an increasing userbase
1 player on launch, 3 players by day 6 and 18 players by day 11. 
	
It should be noted that dx analysis is usually a downward trend 
which is meant to measure player dropoff.  
*/

--------------------------------------------------------------------------------------------------

----- The following are some miscellaneous player analytics featuring rankings, aggregations, and summaries. 

----- What is the average player lifetime? 
WITH playtime AS (
	SELECT 
		f.user_id,
		f.first_log_time, 
		l.last_log_time, 
		EXTRACT(EPOCH FROM (last_log_time - first_log_time)) AS player_lifetime
	FROM first_login f
	JOIN last_login l
	ON f.user_id = l.user_id 
)
SELECT
	user_id, 
	ROUND((player_lifetime) / 86400, 2) AS days,
	ROUND((player_lifetime) / 3600, 2) AS hours,
	ROUND((player_lifetime) / 60, 2) AS minutes,
	ROUND((player_lifetime), 2) AS seconds
FROM playtime
WHERE player_lifetime >= 0
ORDER BY hours DESC;
---------------------------------------------------------
SELECT 
	ROUND(AVG(player_lifetime) / 86400, 2) AS avg_days,
	ROUND(AVG(player_lifetime) / 3600, 2) AS avg_hours
FROM playtime
WHERE player_lifetime >= 0;

/*
The avg. player lifetime is: 
days  |   Hours  |
------+----------+
6.05  |  145.23  |
------+----------+


Top 3 players with the most time are: 
  players   |     days    |   hours     |    minutes    |      seconds    |
------------+-------------+-------------+---------------+-----------------+
d5a0c8e2f   |      12.85  |     308.33  |    18,499.97  |    1109998.00   |
a3e7b4c0d9  |      09.87  |     236.80  |    14,203.18  |     852491.00   |
7d1b0e6f4a  |      07.68  |     184.34  |    11,060.45  |     663627.00   |
------------+-------------+-------------+---------------+-----------------+
*/

----- what percentage of poeple are still playing? 
WITH playtime AS (
    SELECT 
        f.user_id AS players,
        f.first_log_time AS first_login, 
        l.last_log_time AS last_login,
        EXTRACT(EPOCH FROM (l.last_log_time - f.first_log_time) / 86400) AS player_lifetime
    FROM first_login f
    JOIN last_login l
    ON f.user_id = l.user_id 
),
remaining_players AS (
	SELECT 
		COUNT(players):: numeric AS remaining_players
	FROM playtime
	WHERE player_lifetime >= 6.05
),
total_players AS(
	SELECT 
		COUNT(players):: numeric AS total_players
	FROM playtime	
)
SELECT 
	ROUND((remaining_players / total_players)*100, 2) AS player_retention
FROM 
	remaining_players, 
	total_players
/*
Using the average player lifetime as a benchmark, 
Where the average plater lifetime being 6.05 days, the number of players still playing is 42.86%
*/	

	
----- Player Rankings.	
----- what is the total damage that each player took?
SELECT 
	user_id AS player,
	SUM(damage_taken) AS total_damage
FROM player_deaths 
GROUP BY user_id
ORDER BY 
	SUM(damage_taken) DESC;	
/*
   player   |   total_damage  |
------------+-----------------+
c5d8a9f1e2  |            68   | 
9e1a3c7f5b  |            65   |
d7f1e9b2a4  |            61   |
4d6a2f8c1e  |            60   |
8b0e7f3c9a  |            56   |
a2e4f8c6b0  |            13   |
b6f2d5a8c0  |            11   |
f1d5a7e0c9  |            10   |
3a5c7e9b1d  |             9   |
e2b9d4a6f8  |             8   |
------------+-----------------+
*/


-- What is the average total damage taken? 
SELECT
	ROUND(SUM(damage_taken) / COUNT(DISTINCT user_id), 2) AS avg_dmg_taken
FROM player_deaths
/*
The average total damage taken among the group is ~36.00 points. 
*/

	
-- what player took the most/least damage?
SELECT
	user_id, 
	SUM(damage_taken)
FROM player_deaths
GROUP BY user_id 
ORDER BY 
	SUM(damage_taken) DESC
		
/*
Top Player: 
    player   |  damage  |
-------------+----------+
e2b9d4a6f8   |      8   |
-------------+----------+
	
Bottom Player: 
    player   |  damage  |
-------------|----------|
c5d8a9f1e2   |     68   | 
-------------+----------+
*/

	
----- which player died the most/least?
SELECT 
	user_id AS player, 
	COUNT(user_id) AS num_deaths
FROM player_deaths 
GROUP BY user_id
ORDER BY 
	COUNT(user_id) DESC
/*
most deaths: 
      user   |  deaths  |
-------------+----------+
c5d8a9f1e2   |       7  |
-------------+----------+

least deaths: 
      user   |  deaths  |
-------------+----------+ 
e2b9d4a6f8   |       1  |
-------------+----------+
*/

----- Player Segmentation
----- what time of day do players die the most?
WITH day_time AS (
	SELECT 
		user_id, 
		CASE
			WHEN EXTRACT(HOUR FROM time_death) BETWEEN 6 AND 11 THEN 'Morning'
			WHEN EXTRACT(HOUR FROM time_death) BETWEEN 12 AND 17 THEN 'Afternoon'
			WHEN EXTRACT(HOUR FROM time_death) BETWEEN 18 AND 23 THEN 'Evening'
			ELSE 'Night'
		END AS time_of_day
	FROM player_deaths
)
SELECT 
	time_of_day, 
	COUNT(user_id)
FROM day_time
GROUP BY time_of_day
ORDER BY 
	COUNT(user_id) DESC

/*
time of day  |  deaths  |
-------------+----------+
Morning      |     13   |
Afternoon    |     11   |  
Night        |      8   |
Evening      |      8   |
-------------+----------+

It appears that more deaths occur in the morning, 
between the hours of 6 and 11

Note: Could be useful in determining player segmentation, 
eg: what time of day do certain players play? 
ie: more casual players play in the morning.
*/
