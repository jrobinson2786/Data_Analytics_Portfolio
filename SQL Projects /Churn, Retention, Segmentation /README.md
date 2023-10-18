# Player Churn, Retention, & Segmentation


I thought this would be a fun project and it falls within a domain of interest. Full disclosure: I don't quite know how to do a segmentation analysis, but I managed to piece something together through articles and various other resources.  

* I start with a player churn analysis, which indicates the percentage of players that have stopped player the game within the given timeframe. (NOTE: This is just an overall churn to gain insights into the data and the games engagement. I did a Dx analysis in a different project ([Link]) (https://github.com/jrobinson2786/Data_Analytics_Portfolio/tree/main/SQL%20Projects%20/DX%20Retention%2C%20Misc.%20Player%20Stats%2C%20) 

* Then I conduct a player retention analysis which presents the number of player still engaged as well as a percentage of the total within the given timeframe. 

* Finally, for the segmentation, calculated each player's completion percentage and grouped the players into segments based on the percentage of levels that they completed in 25% increments. This allowed me to analyze the average tendencies of each group (ie: help used, retry times, success time, etc.)

One important insight that I've discovered while researching segmentation is that these projects have a tendency to start with a general idea then evolve over time with more relevant metrics and user segments. From what I understand, one of the most important aspects of the project are the conversations that it inspires between teammates and stakeholders.


## Here are some the resources that I used for this project: 

* Data Source: Prediction of User Loss in Mobile Games | by Manvictor ([Link]) (https://www.kaggle.com/datasets/manchvictor/prediction-of-user-loss-in-mobile-games)
  - As the title implies, this dataset was initially meant for a machine learning project to predict the the palyer churn rate for a mobile level climber game. A project like that exceeds my current abilities (for now), So I thought it would be a fun project to derive insights from the existing data, even though it only covers four days.

* ### Here are some articles and other resources (in addition to ChatGPT) that used to try and gain an understanding of the churn, retention, and Segmentation process:
  - "User Segmentation Approaches for Games" | by Alyssa Perez [Link] (https://medium.com/googleplaydev/user-segmentation-approaches-for-games-4457aa57d56e)
  -  "Player SEgments Based on Gaming Motivation" | Quantic Foundry [Link] (https://quanticfoundry.com/2020/08/17/player-segments/)
      -- Note: This is a great resource for understanding segmentation, but the data I had for this particular project just didn't go that far. I'll probably use this article again in the future.    
