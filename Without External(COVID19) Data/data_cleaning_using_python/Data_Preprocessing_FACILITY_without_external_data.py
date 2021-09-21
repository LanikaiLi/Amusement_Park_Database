# -*- coding: utf-8 -*-
"""
Created on Sun Sep  5 13:30:15 2021

@author: Xintong
"""
import pandas as pd
import os  # # find the path of storing the raw files
current_path = os.getcwd()
facility_path = current_path + "\\FACILITY_original.csv"
facility_df = pd.read_csv(facility_path, encoding = 'ISO-8859-1')

column_name = ['FACILITY_ID', 'TICKET_ID', 'FACILITY_DESC','FACILITY_TYPE', 'FACILITY_CAPACITY','FACILITY_SUBTYPE','LOCATION','TIMESTAMP']
facility_df.columns = column_name



#Firstly, I need to change the value in facility['TIMESTAMP'] column to datetime version
test = '13/09/2020 12:31'
#I want to convert it to : '2020-09-13 12:31'

#Split into 2 parts
l1 = test.split(" ")
l2 = l1[0].split("/")
#reverse
l3 = l2[::-1]
#join
result1 = "-".join(l3)
result2 = result1 + " "+ l1[1]

#make it a function
def convertToDatetime(text):
    ltemp = text.split(" ")
    ltemp2 = ltemp[0].split("/")
    lreverse = ltemp2[::-1]
    result_temp = "-".join(lreverse)
    final_result = result_temp + " "+ ltemp[1]
    return final_result

date = convertToDatetime("13/09/2020 12:31")

#then use the function for every element in facility['TIMESTAMP']
for i in range(len(facility_df)):
     facility_df.loc[i, 'TIMESTAMP'] = convertToDatetime(facility_df.loc[i, 'TIMESTAMP'])
     
#then, I will need to add a column for facility_df, which is called FACILITY_TICKET_ID
#becasue we will need this column in ticket_facility table in our database
facility_df = facility_df.reset_index()
facility_df = facility_df.rename(columns={"index":"FACILITY_TICKET_ID"})
facility_df['FACILITY_TICKET_ID'] = facility_df.index + 1

#finally, we can select those columns that we will need in the ticket_facility table in order to import using MAMP
ticket_facility_df = facility_df[['FACILITY_TICKET_ID','TICKET_ID','FACILITY_ID','TIMESTAMP']]

#output this df to local csv and then import using MAMP
ticket_facility_df.to_csv('ticket_facility.csv')





#also ,need to select those columns that will be used in facility table
facility_test_df = facility_df[['FACILITY_ID','FACILITY_DESC','FACILITY_TYPE','FACILITY_CAPACITY','FACILITY_SUBTYPE','LOCATION']]
#then output to csv to import
facility_test_df.tocsv('facility_test.csv')