select 1 + '1'

select 1 + cast('1' as int)

select '1999-09-23' + 1

select cast('1999-09-23' as datetime)

select getdate() + 1


select left('1999-09-23', 5)


select left(getdate(), 5)

select left(123456789, 5)

select left(cast(123456789 as varchar(10)), 5)

select right(getdate(), 5)

select SUBSTRING(cast(123456789 as varchar(10)), 5, 2)

select replace(123456789, 5, '巨匠')

select stuff(123456789, 5, 4, '巨匠')

-- 從學生資料表，將「生日」資料值(例1999-09-23)，傳回「西元1999年09月23日」
-- 方法一：直接帶入字串函式
SELECT [學號]
      ,[姓名]
      ,[性別]
      ,[電話]
      ,'西元' + left(cast([生日] as varchar(10)), 4) + '年' + 
		SUBSTRING(cast([生日] as varchar(10)), 6, 2) + '月' +
		right(cast([生日] as varchar(10)), 2) + '日' as [生日]
FROM [教務系統].[dbo].[學生]

 
select concat('高雄市' ,  NULL, '中山一路242號')
select '高雄市' +  NULL + '中山一路242號'


-- 方法二：使用 stuff()

create or alter function date2name(@d date)
returns char(18)
as
begin
	declare @result varchar(18)
	set @result = '西元' + stuff(@d, 5, 1, '年')
	set @result = stuff(@result, 10, 1, '月')
	set @result += '日'
	return @result
end


SELECT [學號]
      ,[姓名]
      ,[性別]
      ,[電話]
      ,dbo.date2name([生日]) as [生日]
FROM [教務系統].[dbo].[學生]


-- 方法三：使用 FORMAT() 將資料值格式化
SELECT [學號]
      ,[姓名]
      ,[性別]
      ,[電話]
      ,format([生日], '西元yyyy年MM月dd日') as [生日]
FROM [教務系統].[dbo].[學生]


-- 預存程序
exec [sys].[sp_tables]

drop table if exists t1
create table t1
( col1 varchar(50),
  col2 varchar(50),
  col3 varchar(max),
  col4 varchar(50),
  col5 varchar(50) )

insert into t1
exec [sys].[sp_tables]

select * from t1

/* 選課系統
 1)	登入到學校選課系統。
	此程序會搜尋「學生」資料表，就可以帶出學號，例如：S007。
 2) 選擇課程。
	學生在已列出目前可以選課的課程編號進入選課作業，例如：CS222。
 3) 提交。
	a. 此程序會搜尋哪位教授、教室，但目前只能利用「班級」資料表取代「排課」資料表。
    b. 將該名學生已選課後的資料，新增到「班級」資料表中。
*/
--方法一
declare @LoginID char(4) = 'S007'
declare @ProgID char(5) = 'CS222'

select  distinct
		[教授編號],
		[教室]
from [dbo].[班級]
where [課程編號] = @ProgID


insert into [dbo].[班級] ([教授編號], [學號], [課程編號], [上課時間], [教室])
select distinct
		[教授編號],
		@LoginID,
		@ProgID,
		getdate(),
		[教室]
from [dbo].[班級]
where [課程編號] = @ProgID
----------------------------------------------
delete from [dbo].[班級] where [學號] = 'S007'
----------------------------------------------
--方法二
declare @LoginID char(4) = 'S007'
declare @ProgID char(5) = 'CS222'
declare @TechID char(4)
declare @classID char(8)

select  distinct
		@TechID = [教授編號],
		@classID = [教室]
from [dbo].[班級]
where [課程編號] = @ProgID

insert into [dbo].[班級] ([教授編號], [學號], [課程編號], [上課時間], [教室])
values (@TechID, @LoginID, @ProgID, getdate(), @classID)
go

-- 動態 SQL
declare @dbname varchar(20) = 'my123'

execute ('create database ' + @dbname)

/* 題目：使用動態 SQL 建立帳戶
 如何將「學生」資料表每位學生建立「登入」和「使用者」
 並使用統一密碼例如：gjun123
*/

--宣告資料指標
declare StudentRow cursor
for select 學號 from 學生

--開啟資料指標
open studentRow

--讀取資料指標
declare @sqltext1 varchar(max)
declare @sqltext2 varchar(max)

declare @StudentID char(4)
fetch next from StudentRow into @StudentID
--select @StudentID
while @@FETCH_STATUS = 0 begin
	set @sqltext1 =	'create login ' + @StudentID + ' with password=' + quotename('Gjun123', '''')
	--set @sqltext1 =	'create login ' + @StudentID + ' with password= ''Gjun123'''
	set @sqltext2 = 'create user ' + @StudentID + ' for login ' + @StudentID
	execute (@sqltext1)
	execute (@sqltext2)
	fetch next from StudentRow into @StudentID
end



--關閉資料指標
close StudentRow

--移除資料指標
deallocate StudentRow


--demo
declare @t varchar(max) = 
'create login mylogin1 with password=' + QUOTENAME('gjun123', '''')

select @t