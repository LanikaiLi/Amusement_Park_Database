# -*- coding: utf-8 -*-
"""
Created on Fri Sep  3 17:16:27 2021

@author: Admin
"""

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