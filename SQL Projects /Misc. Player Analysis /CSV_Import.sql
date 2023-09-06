
-- Creating database -- 

CREATE TABLE first_login (
	user_id varchar (10),
	first_log_time timestamp
);

COPY first_login 
FROM 'C:\Users\jackj\Desktop\Data Sets\VG data\player_last_login.csv'
DELIMITER ',' CSV HEADER;


CREATE TABLE last_login (
	user_id varchar(10),
	last_log_time timestamp
);

COPY last_login 
FROM 'C:\Users\jackj\Desktop\Data Sets\VG data\player_last_logout.csv'
DELIMITER ',' CSV HEADER;


CREATE TABLE player_deaths (
	user_id varchar(10),
	time_death timestamp,
	damage_taken integer
);

COPY player_deaths 
FROM 'C:\Users\jackj\Desktop\Data Sets\VG data\player_deaths.csv'
DELIMITER ',' CSV HEADER;



