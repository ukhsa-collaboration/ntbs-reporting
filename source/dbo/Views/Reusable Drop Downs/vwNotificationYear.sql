/***************************************************************************************************
Desc:    This SQL query is used to:
		 a) This restricts the notification generation query that runs every night to the lst n years (where n is a deployment variable
		    applied in the publish scripts.
         
**************************************************************************************************/

CREATE VIEW [dbo].[vwNotificationYear] AS

WITH NotificationYears AS 
(
    SELECT 0 AS Id,YEAR(GetDate()) AS NotificationYear
    UNION ALL
    SELECT ny.Id - 1 as Id,ny.NotificationYear -1  as NotificationYear
    FROM NotificationYears ny
    WHERE ny.NotificationYear - 1 >= CONVERT(INT, '$(ReportingStartYear)')
)

SELECT TOP 100 Id,NotificationYear FROM NotificationYears 
ORDER BY NotificationYear DESC

