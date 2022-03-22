CREATE PROCEDURE [dbo].[uspGenerateUnmatchedSpecimensLinkedNotifications]
AS
BEGIN TRY

	DECLARE @PoorQualityMatchCutOff DECIMAL(4,2)
	SELECT @PoorQualityMatchCutOff = mc.AutoMatch FROM [$(NTBS_Specimen_Matching)].dbo.MatchingConfiguration mc WHERE mc.MatchingConfigId=1

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
	WHERE pm.EventType IS NULL AND ppm.EventType IS NULL
	AND mr.weight < @PoorQualityMatchCutOff

	CREATE TABLE #AllLinks (ReferenceLaboratoryNumber NVARCHAR(50), NotificationID int, EventType NVARCHAR(50))
	INSERT INTO #AllLinks SELECT * FROM #PreviousMatch
	INSERT INTO #AllLinks SELECT * FROM #PreviousPossibleMatch
	INSERT INTO #AllLinks SELECT * FROM #PoorQualityMatch

	INSERT INTO [dbo].[UnmatchedSpecimensLinkedNotifications]
	SELECT al.ReferenceLaboratoryNumber
		,al.EventType AS NotificationLinkReason
		,rs.RejectionDate
		,rs.UserDisplayName AS [User]
		,al.NotificationID
		,CASE WHEN rr.Denotified = 0 THEN 'No' ELSE 'YES' END AS Denotified
		,pd.NhsNumber
		,pd.DateOfBirth AS BirthDate
		,pd.FamilyName
		,pd.GivenName
		,cd.Sex
		,pd.Postcode
		,cd.TreatmentPhec AS RegionCode
		FROM #AllLinks al
	LEFT JOIN RecordRegister rr on rr.NotificationId = al.NotificationID
	LEFT JOIN Record_PersonalDetails pd ON pd.NotificationId = al.NotificationID
	LEFT JOIN Record_CaseData cd ON cd.NotificationId = al.NotificationID
	LEFT JOIN dbo.RejectedSpecimen rs ON rs.ReferenceLaboratoryNumber = al.ReferenceLaboratoryNumber AND rs.NotificationId = al.NotificationID AND rs.EventType = al.EventType

	DROP TABLE #PreviousMatch
	DROP TABLE #PreviousPossibleMatch
	DROP TABLE #PoorQualityMatch
	DROP TABLE #AllLinks

END TRY
BEGIN CATCH
	THROW
END CATCH
