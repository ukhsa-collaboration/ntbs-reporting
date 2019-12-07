CREATE PROCEDURE [dbo].[uspProcessMIData]
	
AS
	INSERT INTO [dbo].MIReportData

	--fetch new records from the ReportServer database
	SELECT  
		 els.TimeEnd
		,els.UserName
		,Q1.AdGroup
		,CONCAT(DATEPART(year, els.TimeEnd), '-', DATEPART(ISO_WEEK, els.TimeEnd)) As WeekNum
		,els.ReportID
		,getDate() as DateRetrieved 
	FROM [ReportServer].[dbo].[ExecutionLogStorage] els
	LEFT OUTER JOIN 
		--get just one AD group per user - choosing the 'MIN' arbitrarily
		(SELECT 
				CAST([ACCOUNTNAME] AS nvarchar) AS AccountName, 
				REPLACE(MIN([PERMISSIONPATH]),'PHE\','') AS AdGroup
			FROM [dbo].[UserLookup]
			GROUP BY ACCOUNTNAME) AS Q1
	ON els.Username COLLATE DATABASE_DEFAULT = Q1.AccountName
	WHERE els.TimeEnd > (
	-- the first time this is run, there won't be an existing records in MIReportData, so this CASE
	-- clause allows for an arbitary date to be added which will select all records
		SELECT CASE
			WHEN MAX(md.DateRetrieved) is null THEN '2015-01-01 00:00:00'
			ELSE MAX(md.DateRetrieved)
		END AS 'MaxDate'
		FROM [dbo].MIReportData md)
RETURN 0
