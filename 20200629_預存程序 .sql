/* 切換執行身分
 execute as '使用者名稱'
*/
-- 預存程序
create or alter procedure myp1
with execute as 's001'
as 
begin

	select SUSER_NAME()

end
go




select SUSER_NAME()
execute myp1
select SUSER_NAME()
go


-- 純量值函式
drop function dbo.myf1
go

create or alter function dbo.myf1()
returns varchar(50)
with execute as 's001'
as
begin
	declare @name varchar(50) = (select SUSER_NAME())
	return @name
end
go


select SUSER_NAME()
select dbo.myf1()
select SUSER_NAME()
go




/* 資料庫角色
 使用 [db_datareader] 使其具有資料表讀取(SELECT)能力
 使用 [db_datawriter] 使其具有資料表編輯(INSERT、UPDATE、DELETE)能力
*/

-- 為角色加入成員
alter role db_datareader add member s001

-- 為角色移除成員
alter role db_datareader drop member s001


/* 指派權限
 在「資料表」個別授予權限給使用者帳戶
*/
use [教務系統]
GO

-- 在資料表指派權限
GRANT SELECT ON [dbo].[學生] TO [S002]
GO

-- 在資料表移除權限
revoke select on [dbo].[學生] to [S002]
go


/* 帶「參數」的預存程序
 如同函式一般，使用者可提供「參數」到預存程序
*/
--drop proc myp1
create or alter procedure dbo.myp1
@par1 char(4)
as begin

	select * 
	from [dbo].[學生]
	where [學號] = @par1

end


exec dbo.myp1 's001'
go



-- 傳回預存程序的狀態值
create or alter procedure dbo.myp1
@par1 char(4) = null
as begin

	if @par1 is not null begin
		select * 
		from [dbo].[學生]
		where [學號] = @par1

		return (1)
	end
	else
		return (0)

end


exec dbo.myp1 's002'

--如何取得狀態值
declare @result int
exec @result = dbo.myp1 's002'
select @result [狀態值]
go


--實作：例如：試設計一個預存程序，並完成下列需求：(兩個參數)
--1：作業模式代號，若傳入 1 則執行加入，若傳入 2 則執行移除
--2：建立「登入」和「使用者」
--3：為「使用者」加入 [db_datareader]
--參數1：@par1 作業模式
--參數2：@par2 帳戶名稱

--預存程序雛形1
create or alter procedure dbo.p1
@par1 tinyint = null,
@par2 varchar(20) = null
as
begin

	if @par1 = 1 and @par2 is not null
		begin
			declare @sqltext1 varchar(max)
			declare @sqltext2 varchar(max)
			declare @sqltext3 varchar(max)
			set @sqltext1 = 'create login ' + @par2 + ' with password=' + quotename('Gjun123', '''') + ' MUST_CHANGE, DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON'
			set @sqltext2 = 'create user ' + @par2 + ' for login ' + @par2
			set @sqltext3 = 'alter role db_datareader add member ' + @par2

			execute (@sqltext1)
			execute (@sqltext2)
			execute (@sqltext3)

		end
	else
		begin
			if @par1 is null
				print '未提供第一個參數的「作業模式」參數值'
			if @par2 is null
				print '未提供第二個參數的「帳戶名稱」參數值'
		end
end
go


--測試
execute dbo.p1 1, 'demoUser'
go




--預存程序雛形2 (使用狀態值處理例外行為)
-- 建議：盡可能一個預存程序執行一項作業，如此才能有效控制例外行為
-- 一個預存程序 create login
-- 一個預存程序 create user

-- 次要預存程序1
create or alter procedure dbo.addLogin
@LoginName nvarchar(20)
as
begin
	declare @sqltext1 varchar(max)
	set @sqltext1 = 'create login ' + @LoginName + ' with password=' + quotename('Gjun123', '''') + ' MUST_CHANGE, DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON'

	if not exists (select 1 from sys.sql_logins where name = @LoginName)
		begin
			execute (@sqltext1)
			return (1)
		end
	else
		return (0)		
end
go

-- 次要預存程序2
create or alter procedure dbo.addUser
@UserName nvarchar(20)
as
begin
	declare @sqltext1 varchar(max)
	set @sqltext1 = 'create user ' + @UserName + ' for login ' + @UserName

	if not exists(select 1 from sys.sysusers where name = @UserName)
		begin
			execute (@sqltext1)
			return (1)
		end
	else
		return (0)
end
go




--主要的預存程序
create or alter procedure dbo.p1
@par1 tinyint = null,
@par2 varchar(20) = null
as
begin
	set nocount on
	declare @sqltext1 varchar(max)
	declare @sqltext2 varchar(max)
	declare @sqltext3 varchar(max)
	declare @addLogin_result bit
	declare @addUser_result bit

	if @par1 is not null and @par2 is not null
		begin
			if @par1 = 1
				begin
					
					set @sqltext3 = 'alter role db_datareader add member ' + @par2

					execute @addLogin_result = dbo.addLogin @par2
					execute @addUser_result = dbo.addUser @par2

					if @addLogin_result = 1 and @addUser_result = 1
						execute (@sqltext3)

					if @addLogin_result = 0
						print '登入帳戶已存在'

					if @addUser_result = 0
						print '使用者帳戶已存在'

				end

			if @par1 = 2
				begin
					set @sqltext1 = 'drop login ' + @par2
					set @sqltext2 = 'drop user ' + @par2

					execute (@sqltext1)
					execute (@sqltext2)
				end

		end

	else
		begin
			if @par1 is null
				print '未提供第一個參數的「作業模式」參數值'
			if @par2 is null
				print '未提供第二個參數的「帳戶名稱」參數值'
		end

	set nocount off
end
go




--測試
execute dbo.p1 1, 'demoUser123'
go

select * from sys.sql_logins where name = 'demoUser123'
select * from sys.sysusers where name = 'demoUser123'
go


/* PYTHON
import pyodbc

#Set up the SQL Azure connection
dbsvr = 'LocalHost'
dbname = '教務系統'
dbuser = 'scovan'
dbpass = 'Gjun123'
connstr = 'DRIVER={SQL Server};' + \
        'SERVER=' + dbsvr + ';' + \
        'DATABASE=' + dbname + ';' + \
        'UID=' + dbuser + ';' + \
        'PWD=' + dbpass

conn = pyodbc.connect(connstr)
cursor = conn.cursor()
cursor.execute(
    '''
    execute dbo.p1 1, demoUser123
    ''')
*/



--預存程序雛形3 (使用狀態值處理例外行為)
-- 建議：盡可能一個預存程序執行一項作業，如此才能有效控制例外行為
-- 一個預存程序 create login
-- 一個預存程序 create user

-- 次要預存程序1
create or alter procedure dbo.addLogin
@LoginName nvarchar(20)
as
begin
	declare @sqltext1 varchar(max)
	set @sqltext1 = 'create login ' + @LoginName + ' with password=' + quotename('Gjun123', '''') + ' MUST_CHANGE, DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON'

	if not exists (select 1 from sys.sql_logins where name = @LoginName)
		begin
			execute (@sqltext1)
			return (1)
		end
	else
		return (0)		
end
go

-- 次要預存程序2
create or alter procedure dbo.addUser
@UserName nvarchar(20)
as
begin
	declare @sqltext1 varchar(max)
	set @sqltext1 = 'create user ' + @UserName + ' for login ' + @UserName

	if not exists(select 1 from sys.sysusers where name = @UserName)
		begin
			execute (@sqltext1)
			return (1)
		end
	else
		return (0)
end
go




--主要的預存程序
create or alter procedure dbo.p1
@par1 tinyint = null,
@par2 varchar(20) = null
as
begin
	set nocount on
	declare @sqltext1 varchar(max)
	declare @sqltext2 varchar(max)
	declare @sqltext3 varchar(max)
	declare @addLogin_result bit
	declare @addUser_result bit

	declare @result table (col1 nvarchar(20), col2 nvarchar(50))
	
	if @par1 is not null and @par2 is not null
		begin
			if @par1 = 1
				begin
					
					set @sqltext3 = 'alter role db_datareader add member ' + @par2

					execute @addLogin_result = dbo.addLogin @par2
					execute @addUser_result = dbo.addUser @par2

					if @addLogin_result = 1 and @addUser_result = 1
						execute (@sqltext3)

					if @addLogin_result = 0
						insert into @result
						select 'addLogin', '登入帳戶已存在'

					if @addUser_result = 0
						insert into @result
						select 'addUser', '使用者帳戶已存在'

				end

			if @par1 = 2
				begin
					set @sqltext1 = 'drop login ' + @par2
					set @sqltext2 = 'drop user ' + @par2

					execute (@sqltext1)
					execute (@sqltext2)
				end

		end

	else
		begin
			if @par1 is null
				insert into @result
				select 'p1', '未提供第一個參數的「作業模式」參數值'
			if @par2 is null
				insert into @result
				select 'p1', '未提供第二個參數的「帳戶名稱」參數值'
		end

	select * from @result
	set nocount off
end
go




--測試
execute dbo.p1 1, 'demoUser123'
go

select * from sys.sql_logins where name = 'demoUser123'
select * from sys.sysusers where name = 'demoUser123'
go




--預存程序雛形4 (使用try...catch處理例外行為) + 動態SQL
-- 建議：盡可能一個預存程序執行一項作業，如此才能有效控制例外行為
-- 一個預存程序 create login
-- 一個預存程序 create user

-- 次要預存程序1
create or alter procedure dbo.addLogin
@LoginName nvarchar(20)
as
begin
	declare @sqltext1 varchar(max)
	set @sqltext1 = 'create login ' + @LoginName + ' with password=' + quotename('Gjun123', '''') + ' MUST_CHANGE, DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON'
	
	execute (@sqltext1)
end
go

-- 次要預存程序2
create or alter procedure dbo.addUser
@UserName nvarchar(20)
as
begin
	declare @sqltext1 varchar(max)
	set @sqltext1 = 'create user ' + @UserName + ' for login ' + @UserName

	execute (@sqltext1)
end
go




--主要的預存程序
create or alter procedure dbo.p1
@par1 tinyint = null,
@par2 varchar(20) = null
as
begin
	set nocount on
	declare @sqltext1 varchar(max)
	declare @sqltext2 varchar(max)
	declare @sqltext3 varchar(max)

	declare @result table (col1 nvarchar(20), col2 nvarchar(50))
	
	if @par1 is not null and @par2 is not null
		begin
			if @par1 = 1
				begin
					
					set @sqltext3 = 'alter role db_datareader add member ' + @par2

					-- 處理次要預存程序1 的例外行為
					begin try
						execute dbo.addLogin @par2
					end try
					begin catch
						-- 使用動態SQL的ERROR_PROCEDURE()會傳回NULL
						select ERROR_NUMBER(), ERROR_MESSAGE(), ERROR_PROCEDURE()

						insert into @result
						select 'addLogin', '登入帳戶已存在'
					end catch

					-- 處理次要預存程序2 的例外行為
					begin try
						execute dbo.addUser @par2
					end try
					begin catch
						insert into @result
						select 'addUser', '使用者帳戶已存在'
					end catch

				end

			if @par1 = 2
				begin
					set @sqltext1 = 'drop login ' + @par2
					set @sqltext2 = 'drop user ' + @par2

					execute (@sqltext1)
					execute (@sqltext2)
				end

		end

	else
		begin
			if @par1 is null
				insert into @result
				select 'p1', '未提供第一個參數的「作業模式」參數值'
			if @par2 is null
				insert into @result
				select 'p1', '未提供第二個參數的「帳戶名稱」參數值'
		end

	select * from @result
	set nocount off
end
go




--測試
execute dbo.p1 1, 'demoUser123'
go

select * from sys.sql_logins where name = 'demoUser123'
select * from sys.sysusers where name = 'demoUser123'
go

create login demoUser123 with password='Gjun123'
go







--預存程序雛形5 (使用try...catch處理例外行為) + 不使用動態SQL
-- 建議：盡可能一個預存程序執行一項作業，如此才能有效控制例外行為
-- 一個預存程序 create login
-- 一個預存程序 create user

-- 次要預存程序1
create or alter procedure dbo.addLogin
@LoginName nvarchar(20)
as
begin
	declare @sqltext1 varchar(max)
	set @sqltext1 = 'create login ' + @LoginName + ' with password=' + quotename('Gjun123', '''') + ' MUST_CHANGE, DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON'
	
	-- 假設不使用動態SQL
	create login demoUser123 with password='Gjun123'
	--execute (@sqltext1)
end
go

-- 次要預存程序2
create or alter procedure dbo.addUser
@UserName nvarchar(20)
as
begin
	declare @sqltext1 varchar(max)
	set @sqltext1 = 'create user ' + @UserName + ' for login ' + @UserName

	execute (@sqltext1)
end
go




--主要的預存程序
create or alter procedure dbo.p1
@par1 tinyint = null,
@par2 varchar(20) = null
as
begin
	set nocount on
	declare @sqltext1 varchar(max)
	declare @sqltext2 varchar(max)
	declare @sqltext3 varchar(max)

	declare @result table (col1 nvarchar(20), col2 nvarchar(50))
	
	if @par1 is not null and @par2 is not null
		begin
			if @par1 = 1
				begin
					
					set @sqltext3 = 'alter role db_datareader add member ' + @par2

					-- 處理次要預存程序1 的例外行為
					begin try
						execute dbo.addLogin @par2
					end try
					begin catch
						-- 不使用動態SQL的ERROR_PROCEDURE()則會傳回程序名稱
						select ERROR_NUMBER(), ERROR_MESSAGE(), ERROR_PROCEDURE()

						insert into @result
						select 'addLogin', '登入帳戶已存在'
					end catch

					-- 處理次要預存程序2 的例外行為
					begin try
						execute dbo.addUser @par2
					end try
					begin catch
						insert into @result
						select 'addUser', '使用者帳戶已存在'
					end catch

				end

			if @par1 = 2
				begin
					set @sqltext1 = 'drop login ' + @par2
					set @sqltext2 = 'drop user ' + @par2

					execute (@sqltext1)
					execute (@sqltext2)
				end

		end

	else
		begin
			if @par1 is null
				insert into @result
				select 'p1', '未提供第一個參數的「作業模式」參數值'
			if @par2 is null
				insert into @result
				select 'p1', '未提供第二個參數的「帳戶名稱」參數值'
		end

	select * from @result
	set nocount off
end
go




--測試
execute dbo.p1 1, 'demoUser123'
go

select * from sys.sql_logins where name = 'demoUser123'
select * from sys.sysusers where name = 'demoUser123'
go

create login demoUser123 with password='Gjun123'


