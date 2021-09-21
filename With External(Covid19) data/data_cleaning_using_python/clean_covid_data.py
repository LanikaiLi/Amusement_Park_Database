# -*- coding: utf-8 -*-
"""
Created on Wed Sep  8 20:47:47 2021

@author: Admin
"""

import pandas as pd
from tqdm import tqdm
import string
import os # backups for cleaned tables
import time

current_path = os.getcwd()
covid_path = current_path + "\\cleaned_qc_testing_datasets_prov.csv"
covid_df = pd.read_csv(covid_path, encoding = 'ISO-8859-1')

#drop the province column since we already know it is quebec, so it is useless
covid_df = covid_df.drop(columns = ['province'])

#write a function to convert to datetime
string = '2020/1/23'

def convertDatetime(string):
    l = string.split("/")
    result = "-".join(l)
    return result

string2 = convertDatetime(string)

#then, let's apply this fucntion to covid_df date column
for i in range(len(covid_df)):
    covid_df.loc[i,'date'] = convertDatetime(covid_df.loc[i,'date'])
    
    
#finally we can export the df to csv to import
covid_df.to_csv("covid_data_cleaned_by_python.csv")

#try to clean the raw covid data file
raw_covid_path = current_path + "\\raw_qc_testing_datasets_prov.csv"
raw_covid_df = pd.read_csv(raw_covid_path, encoding = 'ISO-8859-1')

#we need to remove those NaNs, those are the biggest problem
raw_covid2 = raw_covid_df.where(pd.notnull(raw_covid_df), None)

#next thing is to convert date to datetime
raw_covid2['date'] = pd.to_datetime(raw_covid2['date'])
raw_covid2['date'] = raw_covid2['date'].dt.date

#finally, remove province column since we absolutely know these data are all coming from Quebec province
#it is useless
raw_covid2 = raw_covid2.drop(columns = ['province'])

#then we will export it to csv and import it to db
raw_covid2.to_csv("cleaned_raw_covid_data.csv")



#as tested, using this way to import covid data is not good, we will loose those data which has empty values
#so I will first use python to upload the df to database then use database to manipulate those empty values
import mysql.connector
import pandas as pd
import pymysql
from sqlalchemy import create_engine

#extracting data from mysql database
cnx = mysql.connector.connect(user='root', password='root',
                              host='localhost',
                              database='la_ronde_with_covid_data',
                              port = 3306 )



engine = create_engine("mysql+pymysql://{user}:{pw}@localhost/{db}"
                       .format(user="root",
                               pw="root",
                               db="la_ronde_with_covid_data"))

raw_covid2.to_sql('covid19_data_2', con = engine, if_exists = 'append', chunksize = 1000)

"""
what I did later on is:
INSERT INTO 
covid19_data (`date`,`cumulative_unique_people_tested`,`cumulative_unique_people_tested_positive`,`cumulative_unique_people_tested_negative`,`unique_people_tested`,`unique_people_tested_positive`,`unique_people_tested_negative`,`unique_people_tested_positivity_percent`,`samples_analyzed`,`cumulative_samples_analyzed`) 
SELECT `date`,`cumulative_unique_people_tested`,`cumulative_unique_people_tested_positive`,`cumulative_unique_people_tested_negative`,`unique_people_tested`,`unique_people_tested_positive`,`unique_people_tested_negative`,`unique_people_tested_positivity_percent`,`samples_analyzed`,`cumulative_samples_analyzed`
FROM covid19_data_2;
this gives me the correct covid19_data in my database!!
"""

