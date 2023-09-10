/*
Objectives
- join the tables to find the total seconds between logins and logouts
- answer "how much damage did each player take in total"
- what was the average damage taken per death
- what player died the most/least
- what time of day do players die the most (lol not really something anyone would ask)

- also for more advanced stuff you'll want to know retention. So if you assume that instead of deaths those are sessions/logins, you can sort of work out retention data and create retention funnels

- also if you pretend that instead of "last login" it's "first_login" (the first table) you can then make more sense since some of those sample players would have to play many days on end without logging out otherwise
*/

----- What does player playtime look like? 
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
6.05 days .. 145.23 hours

Top 3 players with the most time are: 
d5a0c8e2f.... 12.85 days .. 308.33 hours .. 18,499.97 minutes .. 1109998.00 seconds
a3e7b4c0d9... 09.87 days .. 236.80 hours .. 14,203.18 minutes .. 852491.00 seconds
7d1b0e6f4a... 07.68 days .. 184.34 hours .. 11,060.45 minutes .. 663627.00 seconds
*/

----- What is the player retention rate? 
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
		COUNT(players) AS remaining_players
	FROM playtime
	WHERE player_lifetime >= 6.05
),
total_players AS(
	SELECT 
		COUNT(players) AS total_players
	FROM playtime	
)
SELECT 
	ROUND((remaining_players::numeric / total_players:: numeric)*100, 2) AS player_retention
FROM 
	remaining_players, 
	total_players
/*
Using the average player retention rate of 6.05 days as a benchmark (ie: players that have played more than the average), 
The player retention rate is: 42.86%
*/	

----- what is the total damage that each player took?
SELECT 
	user_id AS player,
	SUM(damage_taken) AS total_damage
FROM player_deaths 
GROUP BY user_id
ORDER BY 
	SUM(damage_taken) DESC;	
/*
c5d8a9f1e2 ... 68
9e1a3c7f5b ... 65
d7f1e9b2a4 ... 61
4d6a2f8c1e ... 60
8b0e7f3c9a ... 56
a2e4f8c6b0 ... 13
b6f2d5a8c0 ... 11
f1d5a7e0c9 ... 10
3a5c7e9b1d .... 9
e2b9d4a6f8 .... 8
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
User: c5d8a9f1e2 ... 7 deaths

least deaths: 
User: e2b9d4a6f8 ... 1 death
*/

	
-- What is the average damage taken? 
SELECT
	ROUND(SUM(damage_taken) / COUNT(DISTINCT user_id), 2) AS avg_dmg_taken
FROM player_deaths
/*
The average damage taken among the group is ~36.00 points/player. 
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
Top Player: e2b9d4a6f8 ........ 8 points
Bottom Player: c5d8a9f1e2 .... 68 points
*/

----- what time of day do players die the most
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
Morning ..... 13
Afternoon ... 11
Night ........ 8 
Evening ...... 8

It appears that more deaths occur in the morning, 
between the hours of 6 and 11

Note: Could be useful in determining player segmentation, 
eg: what time of day do certain players play? 
ie: more casual players play in the morning.
*/

