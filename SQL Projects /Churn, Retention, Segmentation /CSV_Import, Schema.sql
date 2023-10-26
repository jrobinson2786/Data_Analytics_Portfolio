
CREATE TABLE dev (
	
	"user_id" INT
,	"label" INT
);

COPY dev 
FROM 'C:\Users\jackj\Desktop\Data Sets\VG data\Mobile Game Sample\dev.csv'
DELIMITER ',' CSV HEADER;

/*
------------------------
----------dev-----------
------------------------

user_id | label |
--------+-------+
 10932	|    0  |
 10933	|    1  |
 10934	|    0  |
 10935	|    1  |
 10936	|    0  |
   *    |    *  |
   *    |    *  |
   *    |    *  |
--------+-------+    
*/
--------------------------------------------------------------------------

CREATE TABLE train ( 
	
	"user_id" INT
,	"label" INT
);

COPY train
FROM 'C:\Users\jackj\Desktop\Data Sets\VG data\Mobile Game Sample\train.csv'
DELIMITER ',' CSV HEADER;

/*
------------------------
---------train----------
------------------------
user_id | label |
--------+-------+
  2774	|    0  |
  2775	|    0  |
  2776	|    1  |
  2777	|    0  |
  2778	|    1  |
    *   |    *  | 
    *   |    *  | 
    *   |    *  | 
--------+-------+	
*/
----------------------------------------------------------------------------

CREATE TABLE level_meta (

	avg_duration NUMERIC
,	avg_passrate NUMERIC
,	avg_win_duration NUMERIC
,	avg_retrytimes NUMERIC
,	level_id INT
);

COPY level_meta
FROM 'C:\Users\jackj\Desktop\Data Sets\VG data\Mobile Game Sample\level_meta.csv'
DELIMITER ',' CSV HEADER;

/*
------------------------
------level_meta--------
------------------------
 avg_duration  |  avg_passrate  |  avg_win_duration  |   avg_retrytimes  |  level_id  |
---------------+----------------+--------------------+-------------------+------------+
  39.88993977  |   0.944466958  |    35.58275695     |     0.017225428   |     1      |
  60.68397506  |   0.991836283  |    56.71570643     |     0.00463782    |     2      |
  76.94735523  |   0.991231578  |    71.78994262     |     0.004480016	 |     3      |
  58.17034668  |   0.993843362  |    54.84288154     |     0.004761165	 |     4      |
 101.7845773   |   0.95416999   |    85.65054652     |     0.027352706	 |     5      |
        *      |        *       |         *          |           *       |     *      |
        *      |        *       |         *          |           *       |     *      |
        *      |        *       |         *          |           *       |     *      |
---------------+----------------+--------------------+-------------------+------------+
*/
--------------------------------------------------------------------------------------

CREATE TABLE level_seq (

	"user_id" INT 
,	level_id INT 
,	success INT 
,	duration INT
,	restep NUMERIC
,	help INT 
,	date_time TIMESTAMP
);

COPY level_seq
FROM 'C:\Users\jackj\Desktop\Data Sets\VG data\Mobile Game Sample\level_seq.csv'
DELIMITER ',' CSV HEADER;

/*
------------------------
------level_seq--------
------------------------

user_id | level_id | success | duration |      restep    | help |       date_time     |
--------+----------+---------+----------+----------------+------+---------------------+
 10932	|       1  |	  1  |     127	|    0.5         |   0	| 2020-02-01 00:05:00 |
 10932	|       2  |      1  |      69	|    0.703703704 |   0	| 2020-02-01 00:08:00 |
 10932	|       3  |  	  1  |      67	|    0.56	 |   0	| 2020-02-01 00:09:00 |
 10932	|       4  |      1  |      58	|    0.7	 |   0	| 2020-02-01 00:11:00 |
 10932	|       5  |      1  |      83	|    0.666666667 |   0	| 2020-02-01 00:13:00 |
   *    |       *  |      *  |       *  |      *         |   *  |         *           |
   *    |       *  |      *  |       *  |      *         |   *  |         *           |
   *    |       *  |      *  |       *  |      *         |   *  |         *           |
--------+----------+---------+----------+----------------+------+---------------------+


*/

