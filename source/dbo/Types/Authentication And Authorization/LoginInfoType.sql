/***************************************************************************************************
Desc:    This table type is used to retrieve the into SQL imported AD Group membership(s) of the 
         logged-in user at runtime.


         
**************************************************************************************************/

CREATE TYPE [dbo].[LoginInfoType] AS TABLE (
	accountname nvarchar(128) NOT NULL,
	type varchar(50) NOT NULL,
	privilege varchar(50) NOT NULL,
	mappedloginname varchar(100) NOT NULL,
	permissionpath varchar(100) NULL
)
