#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import pandas as pd
import numpy as np
import datetime as datetime
import time
import calendar
import os
import matplotlib.pyplot as plt


# In[ ]:


# Read the dataset
client = pd.read_csv('https://github.com/datasci611/bios611-projects-fall-2019-lcw68/tree/master/project_3/data/CLIENT_191102.tsv',sep='\t',header = 0)
disa_entry = pd.read_csv('https://github.com/datasci611/bios611-projects-fall-2019-lcw68/tree/master/project_3/data/DISABILITY_ENTRY_191102.tsv',sep='\t',header = 0)
disa_exit = pd.read_csv('https://github.com/datasci611/bios611-projects-fall-2019-lcw68/tree/master/project_3/data/DISABILITY_EXIT_191102.tsv',sep='\t',header = 0)
entry_exit = pd.read_csv('https://github.com/datasci611/bios611-projects-fall-2019-lcw68/tree/master/project_3/data/ENTRY_EXIT_191102.tsv',sep='\t',header = 0)
ee_udes = pd.read_csv('https://github.com/datasci611/bios611-projects-fall-2019-lcw68/tree/master/project_3/data/EE_UDES_191102.tsv',sep ='\t',header = 0)
income_entry = pd.read_csv('https://github.com/datasci611/bios611-projects-fall-2019-lcw68/tree/master/project_3/data/INCOME_ENTRY_191102.tsv',sep ='\t',header = 0)
income_exit = pd.read_csv('https://github.com/datasci611/bios611-projects-fall-2019-lcw68/tree/master/project_3/data/INCOME_EXIT_191102.tsv',sep='\t',header = 0)
health_entry = pd.read_csv('https://github.com/datasci611/bios611-projects-fall-2019-lcw68/tree/master/project_3/data/HEALTH_INS_ENTRY_191102.tsv',sep ='\t',header = 0)
health_exit = pd.read_csv('https://github.com/datasci611/bios611-projects-fall-2019-lcw68/tree/master/project_3/data/HEALTH_INS_EXIT_191102.tsv',sep ='\t',header = 0)


# In[56]:


### At first we want to explore the correlation of staying time and some characteristics at entry, so we will create two datasets, one is for
### entry and another one is for exit

#Since we found that client ID and client Unique ID has the same value for 

#Transform the Datetime
entry_exit["Entry Date"] = pd.to_datetime(entry_exit["Entry Date"],format = '%m/%d/%Y')
entry_exit["Exit Date"] = pd.to_datetime(entry_exit["Exit Date"],format = '%m/%d/%Y')
#Create the month and Time difference variable
entry_exit["Entry Month"] = entry_exit["Entry Date"].dt.month
entry_exit["Entry Year"] = entry_exit["Entry Date"].dt.year

entry_exit["Exit Month"] = entry_exit["Exit Date"].dt.month
entry_exit["Exit Year"] = entry_exit["Exit Date"].dt.year

entry_exit["Time Difference"] = entry_exit["Exit Date"] - entry_exit["Entry Date"]
entry_exit["Time Difference"] = entry_exit["Time Difference"].apply(lambda x:x.days)
# We then got the month client who enter the shelter
entrydata = entry_exit[['EE UID','Client ID','Entry Date','Exit Date','Entry Month','Entry Year','Time Difference']]
exitdata = entry_exit[['EE UID','Client ID','Entry Date','Exit Date','Exit Month','Exit Year','Time Difference']]
entrydata.groupby("Entry Month").count()["Client ID"].plot(kind = "bar",x = "Entry Month")
plt.savefig("../result/Entry_month.png")
plt.show()


# In[55]:


#See the visiting frequency of year
entrydata.groupby("Entry Year").count()["Client ID"].plot(kind = "bar",x = "Entry Year")
plt.savefig("../result/Entry_year.png")
plt.show()


# In[57]:


exitdata.groupby("Exit Year").count()["Client ID"].plot(kind = "bar",x = "Exit Year")
plt.savefig("../result/Exit_year.png")
plt.show()


# In[7]:


visit = pd.DataFrame(entrydata.groupby("Client ID")["EE UID"].count()).rename(columns = {"EE UID":"Visit_time"})
entrydata1 = pd.merge(entrydata,visit,on="Client ID",how = "left")
entrydata1.groupby("Client ID").mean()["Visit_time"].sort_values(ascending = False)
# The most frequent one comes for 37 times


# In[8]:


exitdata.head()


# In[9]:


# Notice that we could see what kind of reasons make people leave the shelter
entry_exit["Reason for Leaving"].value_counts().apply(lambda x:x/2459)
# Only 21% people completed the program


# In[14]:


#Deal with the Disability Data: 
# We regard the Yes in "Disability Determination" as the variables we want to calculate
disa_entry["Disability Start Date (Entry)"] = pd.to_datetime(disa_entry["Disability Start Date (Entry)"],format = '%m/%d/%Y')
disa_exit["Disability Start Date (Exit)"] = pd.to_datetime(disa_exit["Disability Start Date (Exit)"],format = '%m/%d/%Y')
disen = disa_entry[['EE UID','Client ID']]
disex = disa_exit[['EE UID','Client ID']]
tp = pd.DataFrame(disa_entry.groupby("Client ID")["Disability Determination (Entry)"].apply(lambda x:(x=="Yes (HUD)").sum())).rename(columns = {"Disability Determination (Entry)":"Disability count"})
tq = pd.DataFrame(disa_exit.groupby("Client ID")["Disability Determination (Exit)"].apply(lambda x:(x=="Yes (HUD)").sum())).rename(columns = {"Disability Determination (Exit)":"Disability count"})

disen = pd.merge(disen,tp,on="Client ID",how = "left")
disex = pd.merge(disex,tq,on="Client ID",how = "left")
# Also we could explore how many types every client have at entry
disa_entry[['Client ID','Disability Type (Entry)']].drop_duplicates().groupby("Client ID").count().sort_values(by = "Disability Type (Entry)",ascending= False)


# In[15]:


disa_entry["Disability Type (Entry)"].value_counts()
#The main disability type shows as below


# In[36]:


# Deal with demographic data
# Since we have known the staying time length, we drop the "Client Age at Exit" variables, and some other ID variables.
client_data = pd.DataFrame(client.drop(columns = ["EE Provider ID","Client Unique ID","Client Age at Exit"],inplace = False))
client_data["Client Veteran Status"].replace('Data not collected (HUD)',np.nan,inplace=True)
client_data["Client Ethnicity"].replace(["Data not collected (HUD)","Client doesn't know (HUD)","Client refused (HUD)"],np.nan,inplace = True)
client.sort_values(by = "Client Age at Entry",ascending = True).reset_index(drop=True).head()


# In[17]:


#Merge the three dataset, client demographic, entry data and disability at entry
client_ee = pd.merge(client_data,entrydata1, on = ["EE UID","Client ID"], how = "left").sort_values(by='Entry Date',ascending = True)
client_ee_exit = pd.merge(client_data,exitdata, on = ["EE UID","Client ID"], how = "left").sort_values(by='Entry Date',ascending = True)
client_ee.groupby(["Client Gender","Client Primary Race"])["EE UID","Client ID"].nunique()
# Check the distribution for gender and races


# In[18]:


client_ee = pd.merge(client_ee,disen,on=["EE UID","Client ID"], how = "left").drop_duplicates()
client_ee_exit = pd.merge(client_ee_exit,disex,on=["EE UID","Client ID"], how = "left").drop_duplicates()
client_ee.head()


# In[19]:


#Add the information about monthly income amount
#Regard all the na in monthly amount as zero
ie = pd.DataFrame(income_entry.groupby("Client ID")["Monthly Amount (Entry)"].sum()).fillna(0)
ie1 = pd.DataFrame(income_exit.groupby("Client ID")["Monthly Amount (Exit)"].sum()).fillna(0)

# We checked the different income source, and compare the entry one and exit one
s1 = income_entry["Income Source (Entry)"].value_counts()
s2 = income_exit["Source of Income (Exit)"].value_counts()
client_ee = pd.merge(client_ee,ie,on="Client ID",how = "left")
client_ee_exit = pd.merge(client_ee_exit,ie1,on="Client ID",how = "left")

pd.DataFrame({'Entry':s1,'Exit':s2})


# In[20]:


#Add the information about health insurance coverage at entry
h1 = health_entry[["Client ID","Covered (Entry)"]].groupby("Client ID")["Covered (Entry)"].apply(lambda x:(x == 'Yes').sum())
h1 = pd.DataFrame(h1)
h2 = health_exit[["Client ID","Covered (Exit)"]].groupby("Client ID")["Covered (Exit)"].apply(lambda x:(x == 'Yes').sum())
h2 = pd.DataFrame(h2)
h2


# In[21]:


# calculate the sum of "Yes", which means the sum of health insurance the client has
client_total = pd.merge(client_ee,h1,on="Client ID",how = "left").drop_duplicates().rename(columns={"Client Age at Entry":"Entry_age","Client Primary Race":"race","Monthly Amount (Entry)":"income_month","Covered (Entry)":"healins"})
client_total["race"].replace(["Client doesn't know (HUD)","Client refused (HUD)","Data not collected (HUD)"],np.nan,inplace= True)
client_total_exit = pd.merge(client_ee_exit,h2,on="Client ID",how = "left").drop_duplicates().rename(columns={"Client Age at Entry":"Entry_age","Client Primary Race":"race","Monthly Amount (Exit)":"income_month_exit","Covered (Exit)":"healins_exit"})
client_total_exit["race"].replace(["Client doesn't know (HUD)","Client refused (HUD)","Data not collected (HUD)"],np.nan,inplace= True)

client_total.head()


# In[1]:


client_total.groupby("race").count()
noncash_entry=pd.read_csv('https://github.com/datasci611/bios611-projects-fall-2019-lcw68/tree/master/project_3/data/NONCASH_ENTRY_191102.tsv',sep="\t",header = 0)
nc_entry = pd.DataFrame(noncash_entry[["Client ID","Receiving Benefit (Entry)"]].groupby("Client ID")["Receiving Benefit (Entry)"].apply(lambda x:(x == 'Yes').sum()))
client_total_entry = pd.merge(client_total,nc_entry,on="Client ID",how = "left")

noncash_exit=pd.read_csv('https://github.com/datasci611/bios611-projects-fall-2019-lcw68/tree/master/project_3/data/NONCASH_EXIT_191102.tsv',sep="\t",header = 0)
nc_exit = pd.DataFrame(noncash_exit[["Client ID","Receiving Benefit (Exit)"]].groupby("Client ID")["Receiving Benefit (Exit)"].apply(lambda x:(x == 'Yes').sum()))
client_total_exit = client_total_exit.merge(nc_exit,on="Client ID",how = "left")


# In[23]:


#For living situation data, we are intersted in 
client_living = ee_udes[["EE UID","Housing Status(2703)","Covered by Health Insurance(4376)","Total number of months homeless on the street, in ES or SH in the past three years(5168)","Prior Living Situation(43)"]].rename(columns = {"Covered by Health Insurance(4376)":"HI status","Total number of months homeless on the street, in ES or SH in the past three years(5168)":"homelesstime","Prior Living Situation(43)":"Living"})
client_living[["HI status"]] = client_living[["HI status"]].apply(lambda x: (x == "No (HUD)")*0+(x == "Yes (HUD)")*1)
client_living.groupby("Housing Status(2703)").count()
# We found that most of clients is homeless, so we dont't need to pay much attention to that variables
client_living["homelesstime"].value_counts()
client_living["homelesstime"].replace(['One month (this time is the first month) (HUD)','2','3','4','5','6'],'< 6 months',inplace = True)
client_living["homelesstime"].replace(['7','8','9','10','11','12'],'7-12 months',inplace = True)
client_living["homelesstime"].replace("More than 12 months (HUD)", ">12 months",inplace = True)
client_living["homelesstime"].replace(['Data not collected (HUD)',"Client doesn't know (HUD)","Client refused (HUD)"],np.nan,inplace=True)
client_total_entry = client_total_entry.merge(client_living[["EE UID","homelesstime"]],on = "EE UID", how = "left")
client_total_exit = client_total_exit.merge(client_living[["EE UID","homelesstime"]],on = "EE UID", how = "left")


# In[48]:


client_total_entry["Client Ethnicity"].replace(["Data not collected (HUD)","Client doesn't know (HUD)","Client refused (HUD)"],np.nan,inplace = True)

client_total_entry.to_csv("../data/client_total_entry.tsv",sep="\t")
client_total_exit.to_csv("../data/client_total_exit.tsv",sep="\t")
#Output the file we need 


# In[50]:


client_demographic = client_total_entry.drop(columns=["EE UID","Entry_age","Entry Date","Exit Date","Entry Month","Entry Year","Time Difference"]).drop_duplicates()

client_demographic.to_csv("../data/client_demographic.tsv",sep="\t")

client_demographic[["race","Client Gender","Client Ethnicity","Client Veteran Status"]].describe()
client_demographic.describe(include='all')
# Generate a summary


# In[26]:


print(ee_udes["Prior Living Situation(43)"].value_counts())
ee_udes["Length of Stay in Previous Place(1934)"].value_counts()
# See what kind of values of living situation 

