CREATE VIEW [dbo].[vwUnmatchedSpecimensLinkedNotifications]
	AS 
	
	SELECT us.ReferenceLaboratoryNumber
		,CASE
			WHEN nsm.MatchType = 'Rejected-Possible' THEN 'Possible match rejected by ' + u.DisplayName + ' on ' + FORMAT(a.AuditDateTime, 'dd MMM yyyy')
			WHEN nsm.MatchType = 'Rejected' THEN 'Confirmed match rejected by ' + u.DisplayName + ' on ' + FORMAT(a.AuditDateTime, 'dd MMM yyyy')
		END AS Notes
		,nsm.NotificationID
		,p.NhsNumber
		,p.Dob
		from vwUnmatchedSpecimens us
	JOIN [$(NTBS_Specimen_Matching)].dbo.NotificationSpecimenMatch nsm on nsm.ReferenceLaboratoryNumber = us.ReferenceLaboratoryNumber
	JOIN [$(NTBS_AUDIT)].dbo.AuditLogs a on a.OriginalId = nsm.ReferenceLaboratoryNumber
	JOIN [$(NTBS)].dbo.[User] u on u.Username = a.AuditUser
	JOIN [$(NTBS)].dbo.Patients p on p.NotificationId = nsm.NotificationId
	WHERE nsm.MatchType = 'Rejected' or nsm.MatchType = 'Rejected-Possible'

	--,

	--Poor quality matches?
	--Unmatched by notification?
	--If any confirmed, don't need any rows?

	--Start at vwUnmatchedSpecimens, join to nsm, join to audit logs
	--nsm has an edit field? Where to get history?
	--When matched/unmatched, nsm is just updated.
	--Could look at alerts?
	--Could look at audit logs again
	--Only 400 unmatched specimens

	--AllMatches AS
	--(
	--	SELECT * FROM PreviousPossibleMatches 
	--	UNION 
	--	SELECT * FROM PreviousConfirmedMatches
	--)
	
	
	--SELECT ReferenceLaboratoryNumber
	--		,CASE
	--			WHEN am.MatchType = 'Rejected-Possible' THEN 'Possible match rejected by ' + am.DisplayName + ' on ' + FORMAT(am.AuditDateTime, 'dd MMM yyyy')
	--			WHEN am.MatchType = 'Rejected' THEN 'Confirmed match rejected by ' + am.DisplayName + ' on ' + FORMAT(am.AuditDateTime, 'dd MMM yyyy')
	--		END AS Notes
	--		,am.NotificationID
	--		,p.NhsNumber
	--		,p.Dob
	--FROM AllMatches am
	--JOIN [$(NTBS)].dbo.Patients p on p.NotificationId = am.NotificationId

