# -*- coding: utf-8 -*-
"""
Created on Fri Sep  3 19:11:11 2021

@author: Xintong
"""

import pandas as pd
import os  # # find the path of storing the raw files
current_path = os.getcwd()
ticket_path = current_path + "\\TICKET.csv"
ticket_df = pd.read_csv(ticket_path, encoding = 'ISO-8859-1')

column_name = ['TICKET_ID', 'CUSTOMER_ID', 'PURCHASE_DATE', 'PROMO_APPIED', 'CATEGORY_OF_TICKET_ID', 'CATEGORY_OF_TICKET_DESC', 'PAYMENT_METHOD', 'PAYMENT_METHOD_DESC', 'PURCHASE_MODE', 'PRICE']
ticket_df.columns = column_name

distinct_ticket_id = ticket_df['TICKET_ID'].nunique()

type(ticket_df["PRICE"][1])

customer_path = current_path + "\\CUSTOMER.csv"
customer_df = pd.read_csv(customer_path, encoding = 'ISO-8859-1')
#customer_df.loc[0, 'DOB'] = '1968-11-18'
#customer_df.loc[0, 'DATE_OF_REG'] = '2020-4-12'
#customer_df.loc[1, 'DOB'] = '2002-2-18'
#customer_df.loc[1, 'DATE_OF_REG'] = '2020-4-25'


string1 = '2/18/2002'

def convertCustomer(string):
   l = string.split('/')
   month = l[0]
   date = l[1]
   year = l[2]
   ltemp = []
   ltemp.append(year)
   ltemp.append(month)
   ltemp.append(date)
   result_temp = "-".join(ltemp)
   return result_temp

convertCustomer(string1)

#loop through every row of customer table
#change customer.loc[i, 'DOB'] to convertCustomer(customer.loc[i, 'DOB'])
#change customer.loc[i, 'DATE_OF_REG'] to convertCustomer(customer.loc[i, 'DATE_OF_REG'])
for i in range(len(customer_df)):
    customer_df.loc[i, 'DOB'] = convertCustomer(customer_df.loc[i, 'DOB'])
    customer_df.loc[i, 'DATE_OF_REG'] = convertCustomer(customer_df.loc[i, 'DATE_OF_REG'])
    
                                             
customer_df.to_csv("customer_test.csv")






