CREATE VIEW [dbo].[vwApplicationUsage]
	AS

	WITH
	Usage AS 
	(
		SELECT c.ISOYearWeek AS YearWeek, SUM(Q1.NumberOfRows) AS NumberOfAudits
		FROM [Calendar] c
			LEFT OUTER JOIN 
			(SELECT CONVERT(DATE, [AuditDateTime]) AS AuditDate, COUNT(ID) AS NumberOfRows
			FROM [$(NTBS_AUDIT)].[dbo].[AuditLogs]
			WHERE AuditUser != 'SYSTEM'
			GROUP BY CONVERT(DATE, [AuditDateTime])) AS q1 ON q1.AuditDate = c.DateValue
			WHERE c.DateValue BETWEEN '2021-07-10' AND GETUTCDATE()
			GROUP BY C.ISOYearWeek
			ORDER by c.ISOYearWeek DESC
			OFFSET 0 ROWS
    )

	SELECT u.YearWeek AS YearWeek,
	CASE WHEN u.NumberOfAudits IS NULL THEN 0 ELSE u.NumberOfAudits END AS NumberOfAudits
   	FROM Usage u
