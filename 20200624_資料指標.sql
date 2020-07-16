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

select replace(123456789, 5, '���K')

select stuff(123456789, 5, 4, '���K')

-- �q�ǥ͸�ƪ�A�N�u�ͤ�v��ƭ�(��1999-09-23)�A�Ǧ^�u�褸1999�~09��23��v
-- ��k�@�G�����a�J�r��禡
SELECT [�Ǹ�]
      ,[�m�W]
      ,[�ʧO]
      ,[�q��]
      ,'�褸' + left(cast([�ͤ�] as varchar(10)), 4) + '�~' + 
		SUBSTRING(cast([�ͤ�] as varchar(10)), 6, 2) + '��' +
		right(cast([�ͤ�] as varchar(10)), 2) + '��' as [�ͤ�]
FROM [�аȨt��].[dbo].[�ǥ�]

 
select concat('������' ,  NULL, '���s�@��242��')
select '������' +  NULL + '���s�@��242��'


-- ��k�G�G�ϥ� stuff()

create or alter function date2name(@d date)
returns char(18)
as
begin
	declare @result varchar(18)
	set @result = '�褸' + stuff(@d, 5, 1, '�~')
	set @result = stuff(@result, 10, 1, '��')
	set @result += '��'
	return @result
end


SELECT [�Ǹ�]
      ,[�m�W]
      ,[�ʧO]
      ,[�q��]
      ,dbo.date2name([�ͤ�]) as [�ͤ�]
FROM [�аȨt��].[dbo].[�ǥ�]


-- ��k�T�G�ϥ� FORMAT() �N��ƭȮ榡��
SELECT [�Ǹ�]
      ,[�m�W]
      ,[�ʧO]
      ,[�q��]
      ,format([�ͤ�], '�褸yyyy�~MM��dd��') as [�ͤ�]
FROM [�аȨt��].[dbo].[�ǥ�]


-- �w�s�{��
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

/* ��Ҩt��
 1)	�n�J��Ǯտ�Ҩt�ΡC
	���{�Ƿ|�j�M�u�ǥ͡v��ƪ�A�N�i�H�a�X�Ǹ��A�Ҧp�GS007�C
 2) ��ܽҵ{�C
	�ǥͦb�w�C�X�ثe�i�H��Ҫ��ҵ{�s���i�J��ҧ@�~�A�Ҧp�GCS222�C
 3) ����C
	a. ���{�Ƿ|�j�M����б¡B�ЫǡA���ثe�u��Q�Ρu�Z�šv��ƪ���N�u�ƽҡv��ƪ�C
    b. �N�ӦW�ǥͤw��ҫ᪺��ơA�s�W��u�Z�šv��ƪ��C
*/
--��k�@
declare @LoginID char(4) = 'S007'
declare @ProgID char(5) = 'CS222'

select  distinct
		[�б½s��],
		[�Ы�]
from [dbo].[�Z��]
where [�ҵ{�s��] = @ProgID


insert into [dbo].[�Z��] ([�б½s��], [�Ǹ�], [�ҵ{�s��], [�W�Үɶ�], [�Ы�])
select distinct
		[�б½s��],
		@LoginID,
		@ProgID,
		getdate(),
		[�Ы�]
from [dbo].[�Z��]
where [�ҵ{�s��] = @ProgID
----------------------------------------------
delete from [dbo].[�Z��] where [�Ǹ�] = 'S007'
----------------------------------------------
--��k�G
declare @LoginID char(4) = 'S007'
declare @ProgID char(5) = 'CS222'
declare @TechID char(4)
declare @classID char(8)

select  distinct
		@TechID = [�б½s��],
		@classID = [�Ы�]
from [dbo].[�Z��]
where [�ҵ{�s��] = @ProgID

insert into [dbo].[�Z��] ([�б½s��], [�Ǹ�], [�ҵ{�s��], [�W�Үɶ�], [�Ы�])
values (@TechID, @LoginID, @ProgID, getdate(), @classID)
go

-- �ʺA SQL
declare @dbname varchar(20) = 'my123'

execute ('create database ' + @dbname)

/* �D�ءG�ϥΰʺA SQL �إ߱b��
 �p��N�u�ǥ͡v��ƪ�C��ǥͫإߡu�n�J�v�M�u�ϥΪ̡v
 �èϥβΤ@�K�X�Ҧp�Ggjun123
*/

--�ŧi��ƫ���
declare StudentRow cursor
for select �Ǹ� from �ǥ�

--�}�Ҹ�ƫ���
open studentRow

--Ū����ƫ���
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



--������ƫ���
close StudentRow

--������ƫ���
deallocate StudentRow


--demo
declare @t varchar(max) = 
'create login mylogin1 with password=' + QUOTENAME('gjun123', '''')

select @t