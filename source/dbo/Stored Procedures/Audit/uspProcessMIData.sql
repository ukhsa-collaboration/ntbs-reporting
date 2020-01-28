CREATE PROCEDURE [dbo].[uspProcessMIData]
	
AS

	EXEC [dbo].uspSeedReportLookup

	

	INSERT INTO [dbo].MIReportData

	--fetch new records from the ReportServer database
	SELECT  
		 els.TimeEnd
		,els.UserName
		,Q1.AdGroup
		,CONCAT(DATEPART(year, els.TimeEnd), '-', DATEPART(ISO_WEEK, els.TimeEnd)) As WeekNum
		,els.ReportID
		,getUTCDate() as DateRetrieved 
	FROM [$(ReportServer)].[dbo].[ExecutionLogStorage] els
	LEFT OUTER JOIN 
		--get just one AD group per user - choosing the 'MIN' arbitrarily
		(SELECT 
				Username,
				(CASE
					WHEN CHARINDEX(',', AdGroups) = 0 THEN AdGroups
					--we have a special group called Admin but this isn't useful for reporting, so take the next group
					WHEN CHARINDEX('ADMIN', AdGroups) != 0 THEN SUBSTRING(AdGroups, CHARINDEX('ADMIN,', AdGroups), CHARINDEX(',', AdGroups)-1)
					ELSE SUBSTRING(AdGroups, 1, CHARINDEX(',', AdGroups)-1)
				END) AS AdGroup
			FROM [$(NTBS)].[dbo].[User]) AS Q1
	ON els.UserName COLLATE DATABASE_DEFAULT = Q1.Username
	WHERE els.TimeEnd > (
	-- the first time this is run, there won't be an existing records in MIReportData, so this CASE
	-- clause allows for an arbitary date to be added which will select all records
		SELECT CASE
			WHEN MAX(md.DateRetrieved) is null THEN '2015-01-01 00:00:00'
			ELSE MAX(md.DateRetrieved)
		END AS 'MaxDate'
		FROM [dbo].MIReportData md)
RETURN 0
