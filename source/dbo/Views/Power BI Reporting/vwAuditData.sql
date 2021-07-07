CREATE VIEW [dbo].[vwAuditData]
	AS
	SELECT DISTINCT EventType, RootId, CONVERT(DATE, AuditDateTime,103) AS AuditDate, AuditUser
	FROM [$(NTBS_AUDIT)].[dbo].[AuditLogs]
	WHERE RootEntity = 'Notification' AND EventType = 'Read'
	UNION
	--user login events
	SELECT DISTINCT 'User login' AS EventType, NULL as RootId, CONVERT(DATE, LoginDate, 103) AS LoginDate, Username
	from [$(NTBS)].[dbo].[UserLoginEvent]
	UNION
	SELECT DISTINCT 'Write' AS EventType, RootId, CONVERT(DATE, AuditDateTime,103) AS AuditDate, AuditUser
	FROM [$(NTBS_AUDIT)].[dbo].[AuditLogs]
	WHERE RootEntity = 'Notification' AND EventType != 'Read' AND EventType != 'Unmatch'
	UNION
	--unmatches
	SELECT EventType, RootId, CONVERT(DATE, AuditDateTime,103) AS AuditDate, AuditUser
	FROM [$(NTBS_AUDIT)].[dbo].[AuditLogs]
	WHERE EventType = 'Unmatch'
