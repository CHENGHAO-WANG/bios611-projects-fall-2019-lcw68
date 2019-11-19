library("tidyverse")
client.entry = read_tsv("client_total.tsv")
client.entry = client.entry%>%select(-X1)
head(client.entry)

# Draw the distribution plot of the staying time at shelter

client.entry %>%drop_na("Time Difference")%>%group_by(`Client ID`)%>%
  summarise(td = mean(`Time Difference`),age = min(Entry_age))%>%arrange(age)%>%mutate(index = 1:2311)%>%ggplot(aes(x=index,y=td))+geom_bar(size = 1.5,alpha = 1,stat="identity")+
  labs(x = "Client Sorted by the year of first time entry",y= "Average Time Difference",title ="Distribution of Staying time")+ylim(c(0,500))

# Draw the plot of Monthly income amount for those who got income;
client.entry%>%drop_na(income_month)%>%ggplot(aes(x=income_month))+geom_histogram(bins = 50,fill = "red")+facet_wrap(~`Client Gender`)+labs(x = "income",y = "Frequency",title = "Income Distribution")
client.entry%>%filter(race %in% c("Black or African American (HUD)","White (HUD)","American Indian or Alaska Native (HUD)"))%>%drop_na(income_month)%>%
  ggplot(aes(x=income_month,fill = `Client Gender`))+geom_histogram(bins = 30)+facet_wrap(~race)+theme_bw()+labs(x = "income",y = "Frequency",title = "Income Distribution")
client.entry%>%drop_na(income_month)%>%ggplot(aes(y=income_month, x = `Client Gender`))+geom_boxplot()
client.entry%>%filter(race %in% c("Black or African American (HUD)","White (HUD)","American Indian or Alaska Native (HUD)"))%>%drop_na(income_month)%>%ggplot(aes(x=race,y=income_month,fill=race))+geom_boxplot()

#Draw the plot of amount of health insurance 
client.entry%>%drop_na(healins)%>%filter(healins < 50)%>%ggplot(aes(x = `Client Gender`,y=healins))+geom_boxplot()
client.entry%>%drop_na(healins)%>%ggplot(aes(x=healins))+geom_histogram(bins = 100)

# Draw the distribution of age 
client.entry%>%drop_na(Entry_age)%>%ggplot(aes(x=Entry_age))+geom_bar()+labs(title = "Age Distribution")+theme_grey()

#Conclude that most clients who entered shelter are around 50 years old.

#Check the correlation between time difference and some other variables
client.entry%>%ggplot(aes(y =`Time Difference`,x = income_month))+geom_point()+geom_smooth(method = "loess")
client.entry%>%ggplot(aes(y =`Time Difference`,x = healins))+geom_point()+geom_smooth()
client.entry%>%drop_na(race)%>%ggplot(aes(x=race,y=`Time Difference`))+geom_boxplot()
client.entry%>%filter(`Client Ethnicity` %in% c("Hispanic/Latino (HUD)","Non-Hispanic/Non-Latino (HUD)"))%>%ggplot(aes(x=`Client Ethnicity`,y=`Time Difference`))+geom_boxplot()

#Construct the model
dt = client.entry%>%filter(race %in% c("Black or African American (HUD)","White (HUD)","American Indian or Alaska Native (HUD)"))
mod1 =lm(`Time Difference`~ Entry_age+`Client Gender`+race+income_month+healins+`Disability count`,data =dt)
plot(mod1)
