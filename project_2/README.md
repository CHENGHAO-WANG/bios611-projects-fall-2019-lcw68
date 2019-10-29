# Project 2 

## Background
The dataset shows some variables that represent support for the people in need by Urban Ministries of Durham, whose aim is to help ending the homeless in the neighborhood. The range of recorded data is around 90 years so that we could explore some interesting phenomenon. It offers us the information about food supply, amount of clothing and hygiene kits, diapers and school kits. We will use the dataset provided by UMD to create a Shiny dashboard to try to help people find the solution on their interesting questions. 

## Potential Questions
I would like to explore some of the questions below:
* The trend of different supplies changing by year, month, week and day, especially food supply. When we change the time unit, we calculate the average number 
* For those who are in the nth(1-1000) place in the list of the person-time who received help from UMD, we would like to see the time interval of their seeking for help, and explore the changing trend of supplies demand.
* I would show different changing tendency plot among any two variables we select to search for their correlation. Also, I will consider the influence brought by quarters. People could selet the quarters they want to see if there's any association between variables and quarters.

## Methods

I will use shiny Dashboard to finish some visualization work, showing a more user-friendly interface to allow the user explore the data by their own, and mainly use ggplot2 to show our result. Because of the encoding environment problem, I could not deploy the app in my own computer, and I feel sorry about the possible confusion.

## Result and Conclusions

The result is in [https://lcw68.shinyapps.io/downloads/](https://lcw68.shinyapps.io/downloads/). We could see that some items are influenced by season, hygiene kits and diapers shows decreasing trend around July. And we could find that there's no obvious clustering characteristics when we draw the plot grouped by quarters, but there's still little association between quarters and the variable correlation we would like to explore. By exploring problem 2, UMD could better understand the specific client's demand and their frequency, which could help assign the resources more efficiently.

### Attention

The name of time interval plot in Problem 2 should be "Time Interval of the adjacent two visit of the client we select", since I could not deploy the app in my computer right now I could not change it right away.