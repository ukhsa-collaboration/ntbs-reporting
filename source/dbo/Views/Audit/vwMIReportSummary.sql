CREATE VIEW [dbo].[vwMIReportSummary]
	AS 
		--get the list of report groups
		WITH cteReportGroup(ReportGroup) AS
		(SELECT distinct rl.ReportGroup FROM ReportLookup rl
		WHERE ReportGroup is not null),

		--get the list of week numbers
		 cteWeekNumber(WeekNumber) AS
		(SELECT TOP 10 [WeekNumber] FROM
		(SELECT DISTINCT
			  [WeekNumber]
      
		  FROM [dbo].[MIReportData]
		  ) as Q1
		ORDER BY [WeekNumber] DESC),

		--then a count of reports per week
		 cteCount (ReportGroup, WeekNumber, NumberofReports) AS
		 (select rl.ReportGroup, mr.WeekNumber, COUNT(ReportID) AS 'NumberofReports' from MIReportData mr, ReportLookup rl
			where mr.ReportID = rl.ItemId
			and rl.ReportGroup is not null
			GROUP BY rl.ReportGroup, mr.WeekNumber)
		
		--then cross-join so there is one row per week and report, inserting a 0 if no runs of that report in that week
		SELECT w.WeekNumber, r.ReportGroup, COALESCE (c.NumberofReports, 0) as NumberofReports
		FROM cteWeekNumber w CROSS JOIN cteReportGroup r
			LEFT OUTER JOIN cteCount as c
			ON c.ReportGroup = r.ReportGroup
			AND c.WeekNumber = w.WeekNumber
