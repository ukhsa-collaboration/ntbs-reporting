CREATE PROCEDURE [dbo].[uspGenerateUnmatchedSpecimensLinkedNotifications]
AS
BEGIN TRY

	-- First populate RejectSpecimenUsers table
	EXEC dbo.uspGenerateRejectedSpecimen

	TRUNCATE TABLE [dbo].[UnmatchedSpecimensLinkedNotifications]
	
	SELECT us.ReferenceLaboratoryNumber, nsm.NotificationID, 'Unmatch' AS EventType INTO #PreviousMatch
	FROM UnmatchedSpecimens us
	JOIN [$(NTBS_Specimen_Matching)].dbo.NotificationSpecimenMatch nsm ON nsm.ReferenceLaboratoryNumber = us.ReferenceLaboratoryNumber
	WHERE nsm.MatchType = 'Rejected'

	SELECT us.ReferenceLaboratoryNumber, nsm.NotificationID, 'RejectPotentialMatch' AS EventType INTO #PreviousPossibleMatch
	FROM UnmatchedSpecimens us
	JOIN [$(NTBS_Specimen_Matching)].dbo.NotificationSpecimenMatch nsm ON nsm.ReferenceLaboratoryNumber = us.ReferenceLaboratoryNumber
	WHERE nsm.MatchType = 'Rejected-Possible'

	SELECT mr.clientsourceID AS ReferenceLaboratoryNumber, mr.rclientsourceID AS NotificationID, 'PoorQualityMatch' AS EventType INTO #PoorQualityMatch
	FROM UnmatchedSpecimens us
	JOIN [$(NTBS_Specimen_Matching)].dbo.MatchResults mr ON mr.clientsourceID = us.ReferenceLaboratoryNumber
	--Exclude any matches that have previously been rejected (otherwise every rejection has an accompanying match)
	LEFT JOIN #PreviousMatch pm on pm.NotificationID = mr.rclientsourceID AND pm.ReferenceLaboratoryNumber = mr.clientsourceID
	LEFT JOIN #PreviousPossibleMatch ppm on ppm.NotificationID = mr.rclientsourceID AND ppm.ReferenceLaboratoryNumber = mr.clientsourceID
	JOIN [$(NTBS_Specimen_Matching)].dbo.MatchingConfiguration mc ON mr.[weight] < mc.AutoMatch
	WHERE pm.EventType IS NULL AND ppm.EventType IS NULL
	-- DACPAC!

	CREATE TABLE #AllLinks (ReferenceLaboratoryNumber NVARCHAR(50), NotificationID int, EventType NVARCHAR(50))
	INSERT INTO #AllLinks SELECT * FROM #PreviousMatch
	INSERT INTO #AllLinks SELECT * FROM #PreviousPossibleMatch
	INSERT INTO #AllLinks SELECT * FROM #PoorQualityMatch

	INSERT INTO [dbo].[UnmatchedSpecimensLinkedNotifications]
	SELECT al.ReferenceLaboratoryNumber
		,CASE
			WHEN al.EventType = 'RejectPotentialMatch' THEN 'Possible match rejected by ' + rs.UserDisplayName + ' on '
			WHEN al.EventType = 'Unmatch' THEN 'Confirmed match rejected by ' + rs.UserDisplayName + ' on '
			WHEN al.EventType = 'PoorQualityMatch' THEN 'Poor quality potential match'
		END AS NotificationLinkReason
		,rs.RejectionDate
		,al.NotificationID
		,n.NotificationStatus
		,p.NhsNumber
		,p.Dob AS BirthDate
		,p.FamilyName
		,p.GivenName
		,sex.[Label] AS [Sex]
		,p.[Address]
		,p.PostcodeToLookup AS Postcode
		,tbs.PHECCode AS RegionCode
		FROM #AllLinks al
	JOIN [$(NTBS)].dbo.[Notification] n ON al.NotificationID = n.NotificationId
	JOIN [$(NTBS)].dbo.Patients p ON p.NotificationId = al.NotificationId
	JOIN [$(NTBS)].ReferenceData.Sex sex ON sex.SexId = p.SexId
	JOIN [$(NTBS)].dbo.HospitalDetails hd ON hd.NotificationId = al.NotificationID
	JOIN [$(NTBS)].ReferenceData.TbService tbs ON tbs.Code = hd.TBServiceCode
	LEFT JOIN dbo.RejectedSpecimen rs ON rs.ReferenceLaboratoryNumber = al.ReferenceLaboratoryNumber AND rs.NotificationId = al.NotificationID AND rs.EventType = al.EventType

	DROP TABLE #PreviousMatch
	DROP TABLE #PreviousPossibleMatch
	DROP TABLE #PoorQualityMatch
	DROP TABLE #AllLinks

END TRY
BEGIN CATCH
	THROW
END CATCH
