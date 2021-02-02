CREATE PROCEDURE [dbo].[uspProcessMIData]
	
AS

	EXEC [dbo].uspSeedReportLookup

	

	INSERT INTO [dbo].MIReportData

	--fetch new records from the ReportServer database
	SELECT  
		 els.TimeEnd
		,els.UserName
		,Q1.AdGroup
		,c.ISOYearWeek AS WeekNum
		,els.ReportID
		,getUTCDate() AS DateRetrieved 
	FROM [$(ReportServer)].[dbo].[ExecutionLogStorage] els
		INNER JOIN [dbo].[Calendar] c ON c.DateValue = CONVERT(DATE, els.TimeEnd)
	LEFT OUTER JOIN 
		
		(SELECT 
				Username,
				--This selects the final AD group in the list, which means we exclude the 'ADMIN' group, which is not
				--useful for this report
				RIGHT(AdGroups, CHARINDEX(',', REVERSE(AdGroups) + ',') - 1) AS AdGroup
			FROM [dbo].[User]) AS Q1
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
