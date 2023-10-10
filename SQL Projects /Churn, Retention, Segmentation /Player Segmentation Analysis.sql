
-----Combine data for segmentation

WITH base_data AS (
	SELECT 
		ls.user_id AS player
	,	ls.level_id AS level
	,	ls.success
	,	ls.help
	,	ls.duration
	,	lm.avg_passrate
	,	lm.avg_win_duration
	FROM level_meta lm
	JOIN level_seq ls
	ON lm.level_id = ls.level_id
),
completed_levels AS (
	SELECT 
		COUNT(success) AS completed
	FROM base_data
	WHERE success = 1
),
-----calculate completion rate per player (query turned to CTE)
user_completion_rate AS (
	SELECT 
		player
	, 	ROUND(COUNT(CASE WHEN success = 1 THEN 1 ELSE NULL END)::numeric 
		/ COUNT(success)*100, 2) AS completion_rate
	FROM base_data
	GROUP BY player
)


/*
Completion rate per player:  
Truncated results...

player  |  Completion_rate  |
--------+-------------------+
6221  	|           100.00  |
781	|           100.00  |
4548    |           100.00  |
  *	|	       *    |
  *     |              *    |
11430   |            99.44  |
591     |            98.44  |
3248	|            98.43  |
  *     |             *     |
  *     |             *     |
4296    |            97.96  |
126	|            97.92  |
4441  	|            97.87  |
  *     |              *    |
  *     |              *    |
5409  	|            90.00  |
6268  	|            89.86  |
12003	|            89.83  |
  *     |              *    |
  *     |              *    |
  *     |              *    |
  *     |              *    |
  *     |              *    |
  *     |              *    |
5123	|            0.00   |
3623	|            0.00   |
5195	|            0.00   |
----------------------------+            
*/

,
segmentation AS (
	SELECT 
		player
	,	CASE 
			WHEN completion_rate BETWEEN 0.00 AND 25.99 THEN 'Rank 1'
			WHEN completion_rate BETWEEN 26.00 AND 50.99 THEN 'Rank 2'
			WHEN completion_rate BETWEEN 51.00 AND 75.99 THEN 'Rank 3'
			WHEN completion_rate BETWEEN 76.00 AND 100.00 THEN 'Rank 4'
		END AS player_segment
	FROM user_completion_rate
)

/*
Grouped by level progress represented as a percentage. 

player_segment   | player_count | 
-----------------+--------------+
Rank 1  	 |          75  |
Rank 2  	 |        1358  |
Rank 3           |        2659  |
Rank 4 	         |        2163  |
--------------------------------+
*/

-- Create a join function to rejoin segmentation and base_data CTEs
-- Next step: find commonalities between the different tiers -- adjust the tiers if necessary. 

,
segmentation_insights AS (
	SELECT 
		bs.player
	,	bs.help
	, 	bs.avg_passrate
	,	bs.duration
	,	bs.avg_win_duration
	,	s.player_segment
	FROM base_data bs
	JOIN segmentation s
	ON bs.player = s.player
)
SELECT 
	player_segment
,	COUNT(DISTINCT player) AS player_count
,	ROUND(AVG(duration), 2) AS avg_time_spent
,	ROUND(AVG(avg_win_duration), 2) AS avg_win_duration
,	SUM(help) AS help_used
FROM segmentation_insights
GROUP BY player_segment
ORDER BY player_segment

/*
player_segment | player_count | avg_time_spent  | avg_win_duration | help_used |
---------------+--------------+-----------------+------------------+-----------+
Rank 1	       |          75  |         85.00   |          114.39  |      822  |
Rank 2	       |        1358  |        107.48   |          114.79  |    18055  |
Rank 3         |        2659  |        113.71   |          110.11  |    20787  |
Rank 4	       |        2163  |        100.36   |          100.38  |     7186  |
-------------------------------------------------------------------------------+
*/
