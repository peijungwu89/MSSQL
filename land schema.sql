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
( 鄉鎮市區 nchar(3),
  交易標的 nvarchar(15),
  土地區段位置建物區段門牌 nvarchar(30),
  土地移轉總面積平方公尺 decimal(6,2),
  都市土地使用分區 nvarchar(2),
  非都市土地使用分區 nvarchar(2),
  非都市土地使用編定 nvarchar(2),
  交易年月日 date,
  交易筆棟數 nvarchar(15),
  移轉層次 nvarchar(15),
  總樓層數 nvarchar(4),
  建物型態 nvarchar(20),
  主要用途 nvarchar(15),
  主要建材 nvarchar(10),
  建築完成年月 date,
  建物移轉總面積平方公尺 decimal(6,2),
  [建物現況格局-房] tinyint,
  [建物現況格局-廳] tinyint,
  [建物現況格局-衛] tinyint,
  [建物現況格局-隔間] nchar(1),
  有無管理組織 nchar(1),
  總價元 int,
  單價元平方公尺 int,
  車位類別 nvarchar(10),
  車位移轉總面積平方公尺 decimal(6,2),
  車位總價元 int,
  備註 nvarchar(100),
  編號 char(19) not null
)
go

drop table if exists land.Build
create table land.Build
( 編號 char(19),
  屋齡 tinyint,
  建物移轉面積平方公尺 decimal(6,2),
  主要用途 nvarchar(15),
  主要建材 nvarchar(10),
  建築完成日期 nvarchar(50),
  總層數 nvarchar(4),
  建物分層 nvarchar(30)
)
go

drop table if exists land.Park
create table land.Park
( 編號 char(19),
  車位類別 nvarchar(10),
  車位價格 int,
  車位面積平方公尺 decimal(6,2)
)
go

drop table if exists land.Land
create table land.Land
( 編號 char(19),
  土地區段位置 nvarchar(10),
  土地移轉面積平方公尺 decimal(6,2),
  使用分區或編定 nvarchar(10)
)
go