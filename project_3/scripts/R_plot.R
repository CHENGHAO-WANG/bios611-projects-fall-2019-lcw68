library("tidyverse")
install.packages('corrplot',dependencies=TRUE,repos='http://cran.us.r-project.org')
library("corrplot")
client.entry = read_tsv("../data/client_total_entry.tsv")
client.entry = client.entry%>%select(-X1)
client.exit = read_tsv("../data/client_total_exit.tsv")
client.exit = client.exit%>%select(-X1)

head(client.entry)
###Notice: most of the plot are in Rmd file, I just leave little part of plots in this file.


# Draw the distribution plot of the staying time at shelter

p1 = client.entry %>%drop_na("Time Difference")%>%group_by(`Client ID`)%>%
  summarise(td = mean(`Time Difference`),age = min(Entry_age))%>%arrange(age)%>%mutate(index = 1:2311)%>%ggplot(aes(x=index,y=td))+geom_bar(size = 1.5,alpha = 1,stat="identity")+
  labs(x = "Client Sorted by the year of first time entry",y= "Duration of Stay",title ="Distribution of Staying time")+ylim(c(0,500))
ggsave("../result/staying time.png",width = 5, height = 4)

# Draw the distribution of visiting times 
client.entry%>%select(`Client ID`,Visit_time)%>%distinct()%>%ggplot(aes(x = Visit_time))+geom_histogram(bins=50)

# For the people who visit the most times, check how long will he stay every time.

client.entry%>%select(`Client ID`,Visit_time)%>%arrange(desc(Visit_time))
client.entry%>%filter(`Client ID` == 320781)%>%ggplot(aes(x=`Entry Date`,y = `Time Difference`))+geom_point(size=1.5)

# Find the correlation between visit times and average duration
client.entry%>%group_by(`Client ID`)%>%summarise(visit = mean(Visit_time),duration = mean(`Time Difference`))%>%
  ggplot(aes(x = visit, y = duration))+geom_point(size = 1.5)+labs(x="visit times",y="duration",title = "Scatterplot of Average Duration")
# Draw the plot of Monthly income amount for those who got income;
client.entry%>%drop_na(income_month)%>%filter(`Client Gender` %in% c("Female","Male"))%>%ggplot(aes(x=income_month))+geom_histogram(bins = 50,fill = "red")+facet_wrap(~`Client Gender`)+labs(x = "income",y = "Frequency",title = "Income Distribution")
ggsave("../result/income distribution by gender.png",width = 6,height = 4)

client.entry%>%filter(race %in% c("Black or African American (HUD)","White (HUD)"),`Client Gender` %in% c("Female","Male"))%>%drop_na(income_month)%>%
  ggplot(aes(x=income_month,fill = `Client Gender`))+geom_histogram(bins = 30)+facet_wrap(~race)+theme_bw()+labs(x = "income",y = "Frequency",title = "Income Distribution")
ggsave("../result/income distribution by race.png",width = 6,height = 4)

client.entry%>%drop_na(income_month)%>%ggplot(aes(y=income_month, x = `Client Gender`,fill = `Client Gender`))+geom_boxplot()
client.entry%>%filter(race %in% c("Black or African American (HUD)","White (HUD)","American Indian or Alaska Native (HUD)"))%>%drop_na(income_month)%>%ggplot(aes(x=race,y=income_month,fill=race))+geom_boxplot()
ggsave("../result/race vs icome.png",width=6,height = 4)
# For race variable, we could divide them into two main category and merge others as NA.
client.entry%>%drop_na(homelesstime)%>%ggplot(aes(y=income_month, x = homelesstime,fill = homelesstime))+geom_boxplot()

#Draw the plot of amount of health insurance 
client.entry%>%drop_na(healins)%>%filter(healins < 50)%>%ggplot(aes(x = `Client Gender`,y=healins))+geom_boxplot()
client.entry%>%drop_na(healins)%>%ggplot(aes(x=healins))+geom_histogram(bins = 100)

# Draw the distribution of age 
client.entry%>%ggplot(aes(x= Entry_age,y=..density..))+geom_histogram(bins = 20, fill = "red")+geom_density(adjust = 0.5,size=1)+ggtitle("Age Distribution")
ggsave("../result/age distribution.png", width = 5, height = 6)
# Draw the distribution of homelesstime
client.entry%>%drop_na(homelesstime) %>% ggplot(aes(x=homelesstime))+geom_bar()
#Conclude that most clients who entered shelter are around 50 years old.


#Check the correlation between time difference and some other variables
client.entry%>%ggplot(aes(y =`Time Difference`,x = income_month))+geom_point()+geom_smooth(method = "loess")+theme_bw()+labs(x="monthly income",title = "correlation between staying time and income")
ggsave("../result/time_diff_income.png",width = 5, height = 4)
client.entry%>%ggplot(aes(y =`Time Difference`,x = healins))+geom_point()+geom_smooth()
ggsave("../result/time_diff_healins.png",width = 5, height = 4)

client.entry%>%drop_na(race)%>%ggplot(aes(x=race,y=`Time Difference`))+geom_boxplot()
client.entry%>%filter(`Client Ethnicity` %in% c("Hispanic/Latino (HUD)","Non-Hispanic/Non-Latino (HUD)"))%>%ggplot(aes(x=`Client Ethnicity`,y=`Time Difference`))+geom_boxplot()
client.entry%>%drop_na(homelesstime)%>%ggplot(aes(x=homelesstime,y=`Time Difference`,fill = homelesstime))+geom_boxplot()
ggsave("../result/duration vs homelesstime.png",width = 5, height = 4)

cordat = as.data.frame(client.entry%>%select(`Time Difference`,income_month,healins,Entry_age,`Disability count`,`Receiving Benefit (Entry)`)%>%drop_na(`Time Difference`,income_month,healins,Entry_age,`Disability count`,`Receiving Benefit (Entry)`))
A = cor(cordat) 
corrplot(A,addCoef.col="grey")
ggsave("../result/corrplot.png",width=6,height=6)
#Check if there's a trend for seasons:

client.entry%>%drop_na(income_month)%>%group_by(`Entry Month`)%>%summarise(money = mean(income_month))%>%ggplot(aes(x=`Entry Month`,y = money))+geom_line()+ 
  labs(x="month",y="item",title = "Income change by entry month")+scale_x_continuous(breaks = seq(0,12,3))+theme_bw()

client.entry%>%drop_na(`Disability count`)%>%ggplot(aes(y =`Disability count`,x = `Entry Month`))+geom_point()

# Compare entry and exit:
client.entry%>%drop_na(income_month)%>%group_by(`Entry Month`)%>%summarise(money = mean(income_month))%>%
  ggplot(aes(x=`Entry Month`,y = money))+geom_line()+ 
  labs(x="month",y="income",title = "Income vs entry month: Any trend?")+scale_x_continuous(breaks = seq(0,12,3))+theme_bw()
ggsave("../result/income change after shelter.png",width = 4, height = 6)


