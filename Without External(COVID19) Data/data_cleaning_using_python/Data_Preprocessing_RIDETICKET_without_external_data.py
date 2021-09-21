# -*- coding: utf-8 -*-
"""
Created on Sun Sep  5 13:11:41 2021

@author: Xintong
"""
import pandas as pd
import os  # # find the path of storing the raw files
current_path = os.getcwd()
ticket_ride_path = current_path + "\\RIDES_TICKETS.csv"
ticket_ride_df = pd.read_csv(ticket_ride_path, encoding = 'ISO-8859-1')

#check to see if the data given in the TIMESTAMP column is usable
type(ticket_ride_df.loc[1,'TIMESTAMP'])
#it shows that it's correct, and I later on also sucessfully import the file
