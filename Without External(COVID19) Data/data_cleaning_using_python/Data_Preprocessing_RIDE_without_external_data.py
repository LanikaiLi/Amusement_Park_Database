# -*- coding: utf-8 -*-
"""
Created on Sun Sep  5 10:29:20 2021

@author: Admin
"""

import pandas as pd
import os  # # find the path of storing the raw files
current_path = os.getcwd()
ride_path = current_path + "\\RIDE.csv"
ride_df = pd.read_csv(ride_path, encoding = 'ISO-8859-1')

column_name = ['RIDE_ID','RIDE_NAME','TYPE_OF_RIDE','CAPACITY_OF_A_RIDE','RIDE_HEIGHT','YEARS_STARTED','DESCRIPTION','MIN_RIDE_HEIGHT','MANUFACTURER','TOP_SPEED(MPH)','TRACK_LENGTH(FT)','ADDITIONAL_FEES']
ride_df.columns = column_name

import mysql.connector
import pandas as pd
import pymysql
from sqlalchemy import create_engine

#extracting data from mysql database
cnx = mysql.connector.connect(user='root', password='root',
                              host='localhost',
                              database='la_ronde_amusement_park',
 
                              port = 3306 )
engine = create_engine("mysql+pymysql://{user}:{pw}@localhost/{db}"
                       .format(user="root",
                               pw="root",
                               db="la_ronde_amusement_park"))

ride_df.to_sql('RIDE2', con = engine, if_exists = 'append', chunksize = 1000)

