library(tidyverse)
library(ggplot2)
library(base)
library(reshape2)
library(ggpubr)
Sys.setlocale("LC_TIME", "English")
#This is for transforming the default language in function weekdays

UMD1 <- read_tsv("https://raw.githubusercontent.com/biodatascience/datasci611/gh-pages/data/project1_2019/UMD_Services_Provided_20190719.tsv")
UMD1$Date <- as.Date(UMD1$Date, "%m/%d/%Y")
#Data Preparation, and the introduction is in READme file.

#clear out the extraneous variable, clear the unmeaningful date and add "year","month","weekday" variable
UMD1 <- UMD1%>%filter(Date <= Sys.Date())%>%select(-Referrals,-`Field1`,-`Field2`,-`Field3`)%>%arrange(Date,`Client File Number`,`Client File Merge`)%>% mutate(year = as.numeric(format(Date,"%Y")))
UMD2 = UMD1 %>% select(Date,year,`Client File Number`,`Food Provided for`,`Food Pounds`,`Clothing Items`,`School Kits`,`Diapers`,`Hygiene Kits`)%>%mutate(month = as.integer(format(Date,"%m")),weekday = weekdays(Date),season = quarters(Date))

# Problem 1
#Construct a function whose variable is y-axis, group based time unit and the year range. Do some Cleaning work in the function
fselect <- function(column,timing,range)
{
  Dat = UMD2%>%drop_na(column)
  if(column == "Food Pounds")
  {
    Dat = Dat %>% filter(`Food Pounds` < 300)
  }
  if(column == "Food Provided for")
  {
    Dat = Dat %>% filter(`Food Provided for`< 100)
  }
  if(column == "Diapers")
  {
    Dat = Dat %>% filter(Diapers < 500)
  }
  Dat = Dat%>%filter(year >= range[1] & year <= range[2])
  
  #When consider the weekday and month, we draw both the boxplot and line chart since the average could not represents the property of data points very clearly
  if(timing == "weekday")
  {
    p = ggplot(Dat,aes(x=get(timing),y=get(column),group = get(timing)))+geom_boxplot()+labs(x=timing,y=column,title="Changing Trend boxplot")+theme_bw()
    Dat = Dat %>%group_by(get(timing))%>%summarise(y.column = mean(get(column)))%>%rename("time unit" = "get(timing)")
    Dat$`time unit` = ordered(Dat$`time unit`,level = c("Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"))
    q = ggplot(Dat,aes(x=`time unit`,y=y.column,group = 1)) + geom_line(size = 0.8)+theme_bw()+labs(x=timing,y=column,title="Changing Trend line chart")
    return(ggarrange(p,q,nrow = 2))
  }
  if(timing == "month")
  {
    p = ggplot(Dat,aes(x=get(timing),y=get(column),group = get(timing)))+geom_boxplot()+labs(x=timing,y=column,title="Changing Trend Boxplot")+theme_bw()+scale_x_discrete(limits = c(1,2,3,4,5,6,7,8,9,10,11,12))
    Dat = Dat %>%group_by(get(timing))%>%summarise(y.column = mean(get(column)))%>%rename("time unit" = "get(timing)")
    q = ggplot(Dat,aes(x=`time unit`,y=y.column)) + geom_line(size = 0.8)+theme_bw()+scale_x_continuous(breaks = seq(1,12,3))+labs(x=timing,y=column,title="Changing Trend line chart")
    return(ggarrange(p,q,nrow = 2))
  }
  if(timing == "year")
  {
    Dat = Dat %>%group_by(get(timing))%>%summarise(y.column = mean(get(column)))%>%rename("time unit" = "get(timing)")
    p = ggplot(Dat,aes(x=`time unit`,y=y.column)) + geom_line(size = 0.8)+theme_bw()+scale_x_continuous(breaks = seq(range[1],range[2],ceiling((range[2]-range[1])/4)))+labs(x=timing,y=column,title="Changing Trend")
    return(p)
  }
  else
  {
    Dat = Dat%>%group_by(get(timing))%>%summarise(y.column = mean(get(column)))%>%rename("time unit" = "get(timing)")
    return(ggplot(Dat,aes(x=`time unit`,y=y.column)) + geom_line(size = 0.8) + theme_bw()+labs(x=timing,y=column,title="Changing Trend"))
  }
}


# Problem 2
# Calculate the client file number and its frequency.
clientamount <- function(p)
{
  clientname = as.numeric(names(sort(table(UMD1$`Client File Number`),decreasing = TRUE)[p]))
  clientfreq = as.numeric(sort(table(UMD1$`Client File Number`),decreasing = TRUE)[p])
  return(c(clientname,clientfreq))
}

#This is the function for calculate the time interval;
differtime <- function(x)
{
  n = length(x)
  y = vector(length = n)
  y[1] = 0
  for(i in 2:n)
  {
    y[i] = x[i] - x[i - 1]
  }
  return(y)
}

# This is the function for generate the time interval plot and calculate the mean by year
client.difference <- function(number)
{
  client.data <- UMD1 %>% select(Date,year,`Client File Number`)%>%filter(`Client File Number` == number,year >= 1999)%>%mutate(interval = differtime(Date),index = 1:length(Date))
  p = ggplot(client.data,aes(x = index,y = interval))+geom_line(size=0.7)+ylim(c(0,365))+labs(x = "Index",y = "Time Interval",title = "Time Interval for Different Client")+theme_bw()
  return(list(p,mean(client.data$interval)))
}

# This is the function for calculating the frequency per year
client.freq <- function(number)
{
  client.data <- UMD1 %>% select(Date,year,`Client File Number`)%>%filter(`Client File Number` == number,year >= 1999)%>%group_by(year)%>%summarise(count = n())
  q = ggplot(client.data, aes(x = year,y = count))+geom_bar(stat = "identity")+labs(x = "Year",y = "Freq number",title = "Visiting times per year")+theme_bw()
  return(list(q,mean(client.data$count)))
}

#Problem 3: Correlation Exploration, will be improved in final project

Corr <- function(string1,string2,range)
{
  tpdata = UMD2 %>% select(Date,year,season,`Client File Number`,`Food Provided for`,`Food Pounds`,`Clothing Items`,Diapers)%>% mutate(Food.average = `Food Pounds`/`Food Provided for`)%>%
    drop_na(string1,string2)%>% filter(`Food Pounds` < 1000, `Food Provided for` > 0, year <= range[2], year >= range[1])
  if(string1 == "Diapers" || string2 == "Diapers")
  {
    tpdata = tpdata%>%filter(Diapers < 1000)
  }
  tpdata%>%ggplot(aes(x = get(string1),y = get(string2),group = season,col = season))+geom_point()+labs(x = string1, y = string2, title= "Scatterplot")+theme_bw()
}
