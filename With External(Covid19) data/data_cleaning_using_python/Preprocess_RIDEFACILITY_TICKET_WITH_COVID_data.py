# -*- coding: utf-8 -*-
"""
Created on Wed Sep  8 21:32:37 2021

@author: Admin
"""

import pandas as pd
import os  # # find the path of storing the raw files

#To begin, Let's process the ticket_ride dataset!
current_path = os.getcwd()
rt_path = current_path + "\\RIDES_TICKETS.csv"
rt_df = pd.read_csv(rt_path, encoding = 'ISO-8859-1')

#firstly, convert the value to df datetime format, it will be easier to manage
rt_df['TIMESTAMP'] = pd.to_datetime(rt_df['TIMESTAMP'])

#extract year, month, date from a timestamp 
#as we could see from the result below, there is many data(the false values) which is not contained in the parent's table
#but that also means that at those times, covid-19 did not have a huge impact on Quebec society
theday = '2020-01-23'
nightmare = pd.to_datetime(theday)
extractday = rt_df['TIMESTAMP'].apply(lambda x: (x.year, x.month,x.day) )
covid_begins = extractday > (nightmare.year, nightmare.month, nightmare.day)

#so next step is remove those data before covid_begins, since they are meaningless
#because here we want to analyze the impact of the epidemic on the real economy, so these data are useless
#to save space, and also to avoid possible errors in our database, we remove them
split_date = pd.datetime(2020,1,23)
rt_final = rt_df.loc[rt_df['TIMESTAMP'] >= split_date]

#finally, we also need to extract date from timestamp and put it to new column
rt_final['date'] = rt_final['TIMESTAMP'].dt.date
#rt_final is the useful data for us, now let's export it to csv and import it to our database!
rt_final.to_csv("ride_ticket_with_covid_data.csv")


#Then, let's process the ticket_facility dataset!
ft_path = current_path + "\\ticket_facility.csv"
ft_df = pd.read_csv(ft_path, encoding = 'ISO-8859-1')

ft_df['TIMESTAMP'] = pd.to_datetime(ft_df['TIMESTAMP'])

split_date = pd.datetime(2020,1,23)
ft_final = ft_df.loc[ft_df['TIMESTAMP'] >= split_date]

ft_final['date'] = ft_final['TIMESTAMP'].dt.date

ft_final.to_csv("facility_ticket_with_covid_data.csv")