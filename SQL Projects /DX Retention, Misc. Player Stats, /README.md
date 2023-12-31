

# Dx Retention, Misc. Player Stats

This project was completed by using some sample data that was generated with ChatGPT and the help of a friend / mentor who works in the videogame industry. In addition to Dx retention, the data exploration is wrapped up into the analysis to insights into player activity. 

## NOTES:
* For the Dx analysis, I took the "time_death" column and used them for "player_logins" in order to begin to work out a retention metric. This is because there are just more timestamps to work with than the actual login data. For the duration of the project, the "time_death" attribute from player_deaths is actually used to analyze player deaths. The rest of the analysis should be easier
* A Dx analysis typically explores player number of players on D0 - launch, D1 - the first day, D14, & D30. THIS Dx analysis is created around the available data which doesn't contain the relevant days. I suppose I could have just labeled the dates to fit, but for demonstrative purposes, I didn't think that it really mattered.  ¯\\\_(ツ)\_/¯

## process:

* I started by creating tables by importing CSV files.
* Then I worked out a rough Dx analysis. 
* Next, I determined the average player lifetime, the percentage of people who are playing above average, as well as identified the top 3 players who's playtime was above the average.  
* Next, I ranked the players based on the total amount of damage each player took, calculated the average amount of damage taken, and identified the players who took the most/least amount of damage.
* I then identified the players who died the most/least.
* I thought it would be a fun exercise to identify the time of day that players tended to die the most. Not that there are any inherent uses for this, but It COULD be the start of a solid segmentation proiject.

## Resources: 
* "Understanding Churn in Mobile Games: How to Calculate it and Why Players Leave" | Mistplay [Link](https://www.mistplay.com/resources/mobile-game-churn)
* "8 Crucial User Retention Metrics to Track for Your Mobile App" | Mistplay [Link](https://www.mistplay.com/resources/mobile-app-user-retention-metrics#:~:text=3.%20DX%20retention%20%28D1%2C%20D7%2C%20D30%2C%20and%20more%29,-What%20is%20DX%20retention%3F)
* "User Engagement: 5 Awesome Metrics for Growth" | by Paul Boyce [Link](https://blog.popcornmetrics.com/5-user-engagement-metrics-for-growth/#:~:text=D1%2C%20D7%20and%20D30%20retentions,up%20or%20installing%20your%20app)



