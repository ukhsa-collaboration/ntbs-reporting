CREATE VIEW [dbo].[vwUnmatchedSpecimensLinkedNotifications]
	AS 
	
	WITH PreviousMatch AS (
		SELECT us.ReferenceLaboratoryNumber, nsm.NotificationID, nsm.MatchType
		FROM vwUnmatchedSpecimens us
		JOIN [$(NTBS_Specimen_Matching)].dbo.NotificationSpecimenMatch nsm ON nsm.ReferenceLaboratoryNumber = us.ReferenceLaboratoryNumber
		WHERE nsm.MatchType = 'Rejected'
	),

	PreviousPossibleMatch AS (
		SELECT us.ReferenceLaboratoryNumber, nsm.NotificationID, nsm.MatchType
		FROM vwUnmatchedSpecimens us
		JOIN [$(NTBS_Specimen_Matching)].dbo.NotificationSpecimenMatch nsm ON nsm.ReferenceLaboratoryNumber = us.ReferenceLaboratoryNumber
		WHERE nsm.MatchType = 'Rejected-Possible'
	),

	--PoorQualityMatch AS (
	--	-- Update this
	--	SELECT mr.clientsourceID AS ReferenceLaboratoryNumber, mr.rclientsourceID, 'Poor-Quality' AS MatchType 
	--	FROM [$(NTBS_Specimen_Matching)].dbo.MatchResults mr
	--),

	AllMatches AS (
		SELECT * FROM PreviousMatch
		UNION
		SELECT * FROM PreviousPossibleMatch
		--UNION
		--SELECT * FROM PoorQualityMatch
	)

	SELECT am.ReferenceLaboratoryNumber
		,CASE
			WHEN am.MatchType = 'Rejected-Possible' THEN 'Rejected possible match'
			WHEN am.MatchType = 'Rejected' THEN 'Rejected confirmed match'
			--WHEN am.MatchType = 'Poor-Quality' THEN 'Poor quality potential match'
		END AS NotificationLinkReason
		,am.NotificationID
		,n.NotificationStatus
		,p.NhsNumber
		,p.Dob AS BirthDate
		,UPPER(p.FamilyName) + ', ' + p.GivenName AS [Name]
		,sex.[Label] AS [Sex]
		,p.[Address]
		,p.PostcodeToLookup AS Postcode
		,tbs.PHECCode AS RegionCode
		FROM AllMatches am
	JOIN [$(NTBS)].dbo.[Notification] n ON am.NotificationID = n.NotificationId
	JOIN [$(NTBS)].dbo.Patients p ON p.NotificationId = am.NotificationId
	JOIN [$(NTBS)].ReferenceData.Sex sex ON sex.SexId = p.SexId
	JOIN [$(NTBS)].dbo.HospitalDetails hd ON hd.NotificationId = am.NotificationID
	JOIN [$(NTBS)].ReferenceData.TbService tbs ON tbs.Code = hd.TBServiceCode
