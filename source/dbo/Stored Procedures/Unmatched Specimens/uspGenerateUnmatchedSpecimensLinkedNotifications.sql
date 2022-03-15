CREATE PROCEDURE [dbo].[uspGenerateUnmatchedSpecimensLinkedNotifications]
AS
BEGIN TRY

	-- First populate RejectSpecimenUsers table
	EXEC dbo.uspGenerateRejectSpecimenUsers

	TRUNCATE TABLE [dbo].[UnmatchedSpecimensLinkedNotifications]
	
	SELECT us.ReferenceLaboratoryNumber, nsm.NotificationID, 'Unmatch' AS EventType INTO #PreviousMatch
	FROM vwUnmatchedSpecimens us
	JOIN [$(NTBS_Specimen_Matching)].dbo.NotificationSpecimenMatch nsm ON nsm.ReferenceLaboratoryNumber = us.ReferenceLaboratoryNumber
	WHERE nsm.MatchType = 'Rejected'

	SELECT us.ReferenceLaboratoryNumber, nsm.NotificationID, 'RejectPotentialMatch' AS EventType INTO #PreviousPossibleMatch
	FROM vwUnmatchedSpecimens us
	JOIN [$(NTBS_Specimen_Matching)].dbo.NotificationSpecimenMatch nsm ON nsm.ReferenceLaboratoryNumber = us.ReferenceLaboratoryNumber
	WHERE nsm.MatchType = 'Rejected-Possible'

	--Some strange results here...
	--Ie. some unmatched specimens have a linked poor quality match (with weighting of over 50?!) that definitely belongs to same record
	--Poor quality should be below 35, but lots of confirmed matches with weights in the 20's
	--Can these be defined as poor quality matches?
	SELECT mr.clientsourceID AS ReferenceLaboratoryNumber, mr.rclientsourceID AS NotificationID, 'PoorQualityMatch' AS EventType INTO #PoorQualityMatch
	FROM UnmatchedSpecimens us
	JOIN [$(NTBS_Specimen_Matching)].dbo.MatchResults mr ON mr.clientsourceID = us.ReferenceLaboratoryNumber
	--Exclude any poor quality matches that have previously been rejected
	LEFT JOIN #PreviousMatch pm on pm.NotificationID = mr.rclientsourceID AND pm.ReferenceLaboratoryNumber = mr.clientsourceID
	LEFT JOIN #PreviousPossibleMatch ppm on ppm.NotificationID = mr.rclientsourceID AND ppm.ReferenceLaboratoryNumber = mr.clientsourceID
	WHERE pm.EventType IS NULL AND ppm.EventType IS NULL
	--WHERE mr.weight...

	CREATE TABLE #AllMatches (ReferenceLaboratoryNumber NVARCHAR(50), NotificationID int, EventType NVARCHAR(50))
	INSERT INTO #AllMatches SELECT  * FROM #PreviousMatch
	INSERT INTO #AllMatches SELECT  * FROM #PreviousPossibleMatch
	INSERT INTO #AllMatches SELECT  * FROM #PoorQualityMatch

	INSERT INTO [dbo].[UnmatchedSpecimensLinkedNotifications]
	SELECT am.ReferenceLaboratoryNumber
		,CASE
			WHEN am.EventType = 'RejectPotentialMatch' THEN 'Possible match rejected by ' + u.UserDisplayName + ' on ' + FORMAT(u.RejectionTime, 'dd MMM yyyy')
			WHEN am.EventType = 'Unmatch' THEN 'Confirmed match rejected by ' + u.UserDisplayName + ' on ' + FORMAT(u.RejectionTime, 'dd MMM yyyy')
			WHEN am.EventType = 'PoorQualityMatch' THEN 'Poor quality potential match'
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
		FROM #AllMatches am
	JOIN [$(NTBS)].dbo.[Notification] n ON am.NotificationID = n.NotificationId
	JOIN [$(NTBS)].dbo.Patients p ON p.NotificationId = am.NotificationId
	JOIN [$(NTBS)].ReferenceData.Sex sex ON sex.SexId = p.SexId
	JOIN [$(NTBS)].dbo.HospitalDetails hd ON hd.NotificationId = am.NotificationID
	JOIN [$(NTBS)].ReferenceData.TbService tbs ON tbs.Code = hd.TBServiceCode
	JOIN dbo.RejectSpecimenUsers u ON u.ReferenceLaboratoryNumber = am.ReferenceLaboratoryNumber AND u.NotificationId = am.NotificationID AND u.EventType = am.EventType

	DROP TABLE #PreviousMatch
	DROP TABLE #PreviousPossibleMatch
	DROP TABLE #PoorQualityMatch
	DROP TABLE #AllMatches

END TRY
BEGIN CATCH
	THROW
END CATCH
