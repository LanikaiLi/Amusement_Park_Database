# -*- coding: utf-8 -*-
"""
Created on Fri Sep  3 19:11:11 2021

@author: Admin
"""

import pandas as pd
import os  # # find the path of storing the raw files
current_path = os.getcwd()
path = current_path + "\\TICKET.csv"
ticket_df = pd.read_csv(path, encoding = 'ISO-8859-1')

column_name = ['TICKET_ID', 'CUSTOMER_ID', 'PURCHASE_DATE', 'PROMO_APPIED', 'CATEGORY_OF_TICKET_ID', 'CATEGORY_OF_TICKET_DESC', 'PAYMENT_METHOD', 'PAYMENT_METHOD_DESC', 'PURCHASE_MODE', 'PRICE']
ticket_df.columns = column_name

distinct_ticket_id = ticket_df['TICKET_ID'].nunique()