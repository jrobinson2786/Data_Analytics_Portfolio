/*
Create tables for analysis.
*/

CREATE TABLE player_login (
	user_id varchar (10),
	login_time timestamp
);

COPY player_login 
FROM 'C:\Users\jackj\Desktop\Data Sets\VG data\player_last_login.csv'
DELIMITER ',' CSV HEADER;


CREATE TABLE player_logout (
	user_id varchar(10),
	logout_time timestamp
);

COPY player_logout 
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
