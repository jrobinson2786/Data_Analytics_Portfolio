
------Combined data for player churn/retention analysis

WITH total_users AS(
	SELECT * 
	FROM train
	
	UNION ALL 

	SELECT * 
	FROM dev
), level_seq AS(
	SELECT 
	 	tu.user_id AS players
	,	tu.label
	,	DATE(ls.date_time) AS date
	FROM total_users tu
	JOIN level_seq ls
	ON tu.user_id = ls.user_id
)
----- overall player churn rate between 02.01 and 02.04
,total_count AS (
	SELECT 
		COUNT(DISTINCT players) AS starting_players
	FROM add_seq
	WHERE date = '2020-02-01'
),
end_count AS (
	SELECT 
		COUNT(DISTINCT players) AS remaining_players
	FROM add_seq
	WHERE date = '2020-02-04'
)
SELECT 
	(SELECT starting_players FROM total_count)
,	(SELECT remaining_players FROM end_count) 
,	ROUND(((SELECT starting_players FROM total_count)
		  - (SELECT remaining_players FROM end_count))::numeric
		  / (SELECT starting_players FROM total_count)*100, 2) AS churn_rate
		  
/*
overall churn rate between 02.01 and 02.04:

starting_players | remaining_players | churn_rate |
-----------------+-------------------+------------+
            4960 |             3121  |      37.08 |
-----------------+-------------------+------------+
*/
  
--------------------------------------------------------------------------------
-- player retention between 2020-02-01 and 2020-02-04
SELECT 
	date
,	COUNT(DISTINCT players) AS player_count
,	ROUND(COUNT(DISTINCT players) 
	/ (SELECT COUNT(DISTINCT players)::numeric FROM level_seq)*100, 2) AS retention_percent
FROM level_seq
GROUP BY date
ORDER BY date

  /*
--The player retention between 02.01 and 02.04 is as follows:

       date  |  player_count | retention_% |
-------------+---------------+-------------+
2020-02-01   |	      4960   |      99.14  |
2020-02-02   |	      4253   |      85.01  |
2020-02-03   |        3517   |      70.30  |
2020-02-04   |        3121   |      62.38  |
-------------+---------------+-------------+
*/
