/* �������樭��
 execute as '�ϥΪ̦W��'
*/
-- �w�s�{��
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


-- �¶q�Ȩ禡
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




/* ��Ʈw����
 �ϥ� [db_datareader] �Ϩ�㦳��ƪ�Ū��(SELECT)��O
 �ϥ� [db_datawriter] �Ϩ�㦳��ƪ�s��(INSERT�BUPDATE�BDELETE)��O
*/

-- ������[�J����
alter role db_datareader add member s001

-- �����Ⲿ������
alter role db_datareader drop member s001


/* �����v��
 �b�u��ƪ�v�ӧO�¤��v�����ϥΪ̱b��
*/
use [�аȨt��]
GO

-- �b��ƪ�����v��
GRANT SELECT ON [dbo].[�ǥ�] TO [S002]
GO

-- �b��ƪ����v��
revoke select on [dbo].[�ǥ�] to [S002]
go


/* �a�u�Ѽơv���w�s�{��
 �p�P�禡�@��A�ϥΪ̥i���ѡu�Ѽơv��w�s�{��
*/
--drop proc myp1
create or alter procedure dbo.myp1
@par1 char(4)
as begin

	select * 
	from [dbo].[�ǥ�]
	where [�Ǹ�] = @par1

end


exec dbo.myp1 's001'
go



-- �Ǧ^�w�s�{�Ǫ����A��
create or alter procedure dbo.myp1
@par1 char(4) = null
as begin

	if @par1 is not null begin
		select * 
		from [dbo].[�ǥ�]
		where [�Ǹ�] = @par1

		return (1)
	end
	else
		return (0)

end


exec dbo.myp1 's002'

--�p����o���A��
declare @result int
exec @result = dbo.myp1 's002'
select @result [���A��]
go


--��@�G�Ҧp�G�ճ]�p�@�ӹw�s�{�ǡA�ç����U�C�ݨD�G(��ӰѼ�)
--1�G�@�~�Ҧ��N���A�Y�ǤJ 1 �h����[�J�A�Y�ǤJ 2 �h���沾��
--2�G�إߡu�n�J�v�M�u�ϥΪ̡v
--3�G���u�ϥΪ̡v�[�J [db_datareader]
--�Ѽ�1�G@par1 �@�~�Ҧ�
--�Ѽ�2�G@par2 �b��W��

--�w�s�{������1
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
				print '�����ѲĤ@�ӰѼƪ��u�@�~�Ҧ��v�Ѽƭ�'
			if @par2 is null
				print '�����ѲĤG�ӰѼƪ��u�b��W�١v�Ѽƭ�'
		end
end
go


--����
execute dbo.p1 1, 'demoUser'
go




--�w�s�{������2 (�ϥΪ��A�ȳB�z�ҥ~�欰)
-- ��ĳ�G�ɥi��@�ӹw�s�{�ǰ���@���@�~�A�p���~�঳�ı���ҥ~�欰
-- �@�ӹw�s�{�� create login
-- �@�ӹw�s�{�� create user

-- ���n�w�s�{��1
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

-- ���n�w�s�{��2
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




--�D�n���w�s�{��
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
						print '�n�J�b��w�s�b'

					if @addUser_result = 0
						print '�ϥΪ̱b��w�s�b'

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
				print '�����ѲĤ@�ӰѼƪ��u�@�~�Ҧ��v�Ѽƭ�'
			if @par2 is null
				print '�����ѲĤG�ӰѼƪ��u�b��W�١v�Ѽƭ�'
		end

	set nocount off
end
go




--����
execute dbo.p1 1, 'demoUser123'
go

select * from sys.sql_logins where name = 'demoUser123'
select * from sys.sysusers where name = 'demoUser123'
go


/* PYTHON
import pyodbc

#Set up the SQL Azure connection
dbsvr = 'LocalHost'
dbname = '�аȨt��'
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



--�w�s�{������3 (�ϥΪ��A�ȳB�z�ҥ~�欰)
-- ��ĳ�G�ɥi��@�ӹw�s�{�ǰ���@���@�~�A�p���~�঳�ı���ҥ~�欰
-- �@�ӹw�s�{�� create login
-- �@�ӹw�s�{�� create user

-- ���n�w�s�{��1
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

-- ���n�w�s�{��2
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




--�D�n���w�s�{��
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
						select 'addLogin', '�n�J�b��w�s�b'

					if @addUser_result = 0
						insert into @result
						select 'addUser', '�ϥΪ̱b��w�s�b'

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
				select 'p1', '�����ѲĤ@�ӰѼƪ��u�@�~�Ҧ��v�Ѽƭ�'
			if @par2 is null
				insert into @result
				select 'p1', '�����ѲĤG�ӰѼƪ��u�b��W�١v�Ѽƭ�'
		end

	select * from @result
	set nocount off
end
go




--����
execute dbo.p1 1, 'demoUser123'
go

select * from sys.sql_logins where name = 'demoUser123'
select * from sys.sysusers where name = 'demoUser123'
go




--�w�s�{������4 (�ϥ�try...catch�B�z�ҥ~�欰) + �ʺASQL
-- ��ĳ�G�ɥi��@�ӹw�s�{�ǰ���@���@�~�A�p���~�঳�ı���ҥ~�欰
-- �@�ӹw�s�{�� create login
-- �@�ӹw�s�{�� create user

-- ���n�w�s�{��1
create or alter procedure dbo.addLogin
@LoginName nvarchar(20)
as
begin
	declare @sqltext1 varchar(max)
	set @sqltext1 = 'create login ' + @LoginName + ' with password=' + quotename('Gjun123', '''') + ' MUST_CHANGE, DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON'
	
	execute (@sqltext1)
end
go

-- ���n�w�s�{��2
create or alter procedure dbo.addUser
@UserName nvarchar(20)
as
begin
	declare @sqltext1 varchar(max)
	set @sqltext1 = 'create user ' + @UserName + ' for login ' + @UserName

	execute (@sqltext1)
end
go




--�D�n���w�s�{��
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

					-- �B�z���n�w�s�{��1 ���ҥ~�欰
					begin try
						execute dbo.addLogin @par2
					end try
					begin catch
						-- �ϥΰʺASQL��ERROR_PROCEDURE()�|�Ǧ^NULL
						select ERROR_NUMBER(), ERROR_MESSAGE(), ERROR_PROCEDURE()

						insert into @result
						select 'addLogin', '�n�J�b��w�s�b'
					end catch

					-- �B�z���n�w�s�{��2 ���ҥ~�欰
					begin try
						execute dbo.addUser @par2
					end try
					begin catch
						insert into @result
						select 'addUser', '�ϥΪ̱b��w�s�b'
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
				select 'p1', '�����ѲĤ@�ӰѼƪ��u�@�~�Ҧ��v�Ѽƭ�'
			if @par2 is null
				insert into @result
				select 'p1', '�����ѲĤG�ӰѼƪ��u�b��W�١v�Ѽƭ�'
		end

	select * from @result
	set nocount off
end
go




--����
execute dbo.p1 1, 'demoUser123'
go

select * from sys.sql_logins where name = 'demoUser123'
select * from sys.sysusers where name = 'demoUser123'
go

create login demoUser123 with password='Gjun123'
go







--�w�s�{������5 (�ϥ�try...catch�B�z�ҥ~�欰) + ���ϥΰʺASQL
-- ��ĳ�G�ɥi��@�ӹw�s�{�ǰ���@���@�~�A�p���~�঳�ı���ҥ~�欰
-- �@�ӹw�s�{�� create login
-- �@�ӹw�s�{�� create user

-- ���n�w�s�{��1
create or alter procedure dbo.addLogin
@LoginName nvarchar(20)
as
begin
	declare @sqltext1 varchar(max)
	set @sqltext1 = 'create login ' + @LoginName + ' with password=' + quotename('Gjun123', '''') + ' MUST_CHANGE, DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON'
	
	-- ���]���ϥΰʺASQL
	create login demoUser123 with password='Gjun123'
	--execute (@sqltext1)
end
go

-- ���n�w�s�{��2
create or alter procedure dbo.addUser
@UserName nvarchar(20)
as
begin
	declare @sqltext1 varchar(max)
	set @sqltext1 = 'create user ' + @UserName + ' for login ' + @UserName

	execute (@sqltext1)
end
go




--�D�n���w�s�{��
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

					-- �B�z���n�w�s�{��1 ���ҥ~�欰
					begin try
						execute dbo.addLogin @par2
					end try
					begin catch
						-- ���ϥΰʺASQL��ERROR_PROCEDURE()�h�|�Ǧ^�{�ǦW��
						select ERROR_NUMBER(), ERROR_MESSAGE(), ERROR_PROCEDURE()

						insert into @result
						select 'addLogin', '�n�J�b��w�s�b'
					end catch

					-- �B�z���n�w�s�{��2 ���ҥ~�欰
					begin try
						execute dbo.addUser @par2
					end try
					begin catch
						insert into @result
						select 'addUser', '�ϥΪ̱b��w�s�b'
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
				select 'p1', '�����ѲĤ@�ӰѼƪ��u�@�~�Ҧ��v�Ѽƭ�'
			if @par2 is null
				insert into @result
				select 'p1', '�����ѲĤG�ӰѼƪ��u�b��W�١v�Ѽƭ�'
		end

	select * from @result
	set nocount off
end
go




--����
execute dbo.p1 1, 'demoUser123'
go

select * from sys.sql_logins where name = 'demoUser123'
select * from sys.sysusers where name = 'demoUser123'
go

create login demoUser123 with password='Gjun123'


