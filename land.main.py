#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import pandas as pd
import pyodbc

#Set up the SQL Azure connection
dbsvr = 'LocalHost'
dbname = 'pythondb'
dbuser = '***'
dbpass = '***'
connstr = 'DRIVER={SQL Server};' +         'SERVER=' + dbsvr + ';' +         'DATABASE=' + dbname + ';' +         'UID=' + dbuser + ';' +         'PWD=' + dbpass

conn = pyodbc.connect(connstr)
cursor = conn.cursor()

df = pd.read_csv(r"C:\Users\pgw\Desktop\landcsv\a_lvr_land_a.csv")
df = df.iloc[1:]
df = df.fillna(value='')

for index, row in df.iterrows():
    #print(str((int(row.交易年月日)) + 19110000))
    #print(str((int(row.建築完成年月)) + 19110000))
    row.交易年月日 = str(int(row.交易年月日)+19110000)

    if bool(row.建築完成年月):
        row.建築完成年月 = str(int(row.建築完成年月)+19110000)

    sql_text = '''insert land.main values(
    '{}', '{}', '{}', '{}', '{}', '{}', '{}', '{}', '{}', '{}',\
    '{}', '{}', '{}', '{}', '{}', '{}', '{}', '{}', '{}', '{}',\
    '{}', '{}', '{}', '{}', '{}', '{}', '{}', '{}' )
    '''
    
    #print(sql_text.format(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13], row[14], row[15], row[16], row[17], row[18], row[19], row[20], row[21], row[22], row[23], row[24], row[25], row[26], row[27]))
    sql_text = sql_text.format(row[0], row[1], row[2], row[3], row[4], row[5], row[6], row[7], row[8], row[9], row[10], row[11], row[12], row[13], row[14], row[15], row[16], row[17], row[18], row[19], row[20], row[21], row[22], row[23], row[24], row[25], row[26], row[27])

    cursor.execute(sql_text)

conn.commit()
conn.close()

