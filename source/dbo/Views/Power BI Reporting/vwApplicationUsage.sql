CREATE VIEW [dbo].[vwApplicationUsage]
	AS
    
	WITH
	Usage AS 
	(
        SELECT c.ISOYearWeek AS YearWeek, SUM(Q1.NumberOfRows) AS NumberOfAudits
        FROM [Calendar] c
            LEFT OUTER JOIN 
                (SELECT CONVERT(DATE, [AuditDateTime]) AS AuditDate, COUNT(iD) AS NumberOfRows
                FROM [$(NTBS_AUDIT)].[dbo].[AuditLogs]
                WHERE AuditUser != 'SYSTEM'
                GROUP BY CONVERT(DATE, [AuditDateTime])) as q1 on q1.AuditDate = c.DateValue
            WHERE c.DateValue between '2021-07-10' and GETUTCDATE()
            GROUP BY C.ISOYearWeek
            ORDER by c.ISOYearWeek DESC
            OFFSET 0 ROWS
    )

    SELECT u.YearWeek AS YearWeek,
    CASE WHEN u.NumberOfAudits IS NULL THEN 0 ELSE u.NumberOfAudits END AS NumberOfAudits
    FROM Usage u