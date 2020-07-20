drop table if exists land.Main
drop table if exists land.Park
drop table if exists land.Build
drop table if exists land.Land
go
drop schema if exists land
go
create schema land
go

drop table if exists land.Main
create table land.Main
( �m���� nchar(3),
  ����Ъ� nvarchar(15),
  �g�a�Ϭq��m�ت��Ϭq���P nvarchar(30),
  �g�a�����`���n���褽�� decimal(6,2),
  �����g�a�ϥΤ��� nvarchar(2),
  �D�����g�a�ϥΤ��� nvarchar(2),
  �D�����g�a�ϥνs�w nvarchar(2),
  ����~��� date,
  ������ɼ� nvarchar(15),
  ����h�� nvarchar(15),
  �`�Ӽh�� nvarchar(4),
  �ت����A nvarchar(20),
  �D�n�γ~ nvarchar(15),
  �D�n�ا� nvarchar(10),
  �ؿv�����~�� date,
  �ت������`���n���褽�� decimal(6,2),
  [�ت��{�p�槽-��] tinyint,
  [�ت��{�p�槽-�U] tinyint,
  [�ت��{�p�槽-��] tinyint,
  [�ت��{�p�槽-�j��] nchar(1),
  ���L�޲z��´ nchar(1),
  �`���� int,
  ��������褽�� int,
  �������O nvarchar(10),
  ���첾���`���n���褽�� decimal(6,2),
  �����`���� int,
  �Ƶ� nvarchar(100),
  �s�� char(19) not null
)
go

drop table if exists land.Build
create table land.Build
( �s�� char(19),
  ���� tinyint,
  �ت����ୱ�n���褽�� decimal(6,2),
  �D�n�γ~ nvarchar(15),
  �D�n�ا� nvarchar(10),
  �ؿv������� nvarchar(50),
  �`�h�� nvarchar(4),
  �ت����h nvarchar(30)
)
go

drop table if exists land.Park
create table land.Park
( �s�� char(19),
  �������O nvarchar(10),
  ������� int,
  ���쭱�n���褽�� decimal(6,2)
)
go

drop table if exists land.Land
create table land.Land
( �s�� char(19),
  �g�a�Ϭq��m nvarchar(10),
  �g�a���ୱ�n���褽�� decimal(6,2),
  �ϥΤ��ϩνs�w nvarchar(10)
)
go