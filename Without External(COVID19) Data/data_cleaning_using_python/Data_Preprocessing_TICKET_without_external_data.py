# -*- coding: utf-8 -*-
"""
Created on Sun Sep  5 11:15:20 2021

@author: Xintong
"""

import pandas as pd
import os  # # find the path of storing the raw files
current_path = os.getcwd()
ticket_path = current_path + "\\TICKET.csv"
ticket_df = pd.read_csv(ticket_path, encoding = 'ISO-8859-1')

column_name = ['TICKET_ID', 'C_ID', 'PURCHASE_DATE', 'PROMO_APPLIED', 'CATEGORY_OF_TICKET_ID', 'CATEGORY_OF_TICKET_DESC', 'PAYMENT_ID','PAYMENT_METHOD_ID', 'PAYMENT_METHOD_DESC', 'PURCHASE_MODE', 'PRICE']
ticket_df.columns = column_name


#Select out those columns we need in the payment table
payment_df = ticket_df[['PAYMENT_ID', 'PAYMENT_METHOD_ID','PROMO_APPLIED','PRICE','PURCHASE_MODE']]

#output to local csv in order to import through MAMP
payment_df.to_csv('payment.csv')

#Select out those columns we need in the payment_method table
payment_method_df = ticket_df[['PAYMENT_METHOD_ID','PAYMENT_METHOD_DESC']]

#output to local csv in order to import through MAMP
payment_method_df.to_csv('payment_method.csv')

#check to see how many unique payment_method we have in the csv
payment_method_df['PAYMENT_METHOD_ID'].unique()
#there are 4 of them, so we have successfully imported the table payment_method

#Select out those columns we need in the ticket_category table
ticket_category_df = ticket_df[['CATEGORY_OF_TICKET_ID','CATEGORY_OF_TICKET_DESC']]

#output to local csv in order to import through MAMP
ticket_category_df.to_csv('ticket_category.csv')

#check to see how many unique payment_method we have in the csv
ticket_category_df['CATEGORY_OF_TICKET_ID'].unique()
#there are 3 of them, so we have successfully imported the table TICKET_CATEGORY


#Select out those columns we need in the TICKET table
ticket_for_import_df = ticket_df[['TICKET_ID','C_ID','PAYMENT_ID','CATEGORY_OF_TICKET_ID', 'PURCHASE_DATE']]

ticket_for_import_df['PURCHASE_DATE'] = pd.to_datetime( ticket_for_import_df['PURCHASE_DATE'])
ticket_for_import_df['PURCHASE_DATE'] = ticket_for_import_df['PURCHASE_DATE'].dt.date
#before exporting, I need to correct some mistakes in this df
#since there is a person whose CID is not logically correct, I need to change his CID from CD00010 to CD0001
#because CD00010 does not exist in customer 
#I am doing this under the assumption that "this customer's C_ID is wrongly written in the ticket table, he/she should be CD0001"
ticket_for_import_df['C_ID'] = ticket_for_import_df['C_ID'].replace('CD00010', 'CD0001')

#output to local csv in order to import through MAMP
ticket_for_import_df.to_csv('ticket_for_import.csv')







