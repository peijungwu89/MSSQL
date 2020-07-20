insert into [land].[Main]
EXEC sp_execute_external_script
@language = N'python',
@script = N'
import pandas as pd

df = pd.read_csv(r"C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\PYTHON_SERVICES\sql\a_lvr_land_a.csv")
df = df.iloc[1:]
df = df.fillna(value="")

for index, row in df.iterrows():

    row.交易年月日 = str(int(row.交易年月日)+19110000)

    if bool(row.建築完成年月):
        row.建築完成年月 = str(int(row.建築完成年月)+19110000)
',
@output_data_1_name = N'df'

