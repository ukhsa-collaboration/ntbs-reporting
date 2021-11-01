CREATE PROCEDURE [dbo].[uspGenerateMultiSystemTransfers]
AS
BEGIN TRY
	TRUNCATE TABLE [dbo].[MultiSystemTransfers]

	-- transfers in NTBS to regions not yet on NTBS
	INSERT INTO [dbo].[MultiSystemTransfers] ([NotificationID],
		[NotificationDate],
		[SourceSystem],
		[ETSID],
		[Requester],
		[RequestedCaseManager],
		[RequestedOrganisation],
		[CreatedDate])

	SELECT a.NotificationId, n.NotificationDate, 'NTBS', n.ETSID, requester.Username, requested.Username, tbs.Name, a.CreationDate
	
	FROM [$(NTBS)].dbo.Alert a
		LEFT JOIN [$(NTBS)].dbo.Notification n ON n.NotificationId = a.NotificationId
		LEFT JOIN [$(NTBS)].dbo.HospitalDetails h ON n.NotificationId = h.NotificationId
		LEFT JOIN [$(NTBS)].dbo.[User] requester ON requester.Id = h.CaseManagerId
		LEFT JOIN [$(NTBS)].dbo.[User] requested ON requested.Id = a.CaseManagerId
		LEFT JOIN [$(NTBS)].ReferenceData.TbService tbs ON tbs.Code = a.TbServiceCode
		LEFT JOIN [dbo].NtbsTransitionDateLookup transition ON transition.PHEC = tbs.PHECCode
	WHERE
		a.AlertType = 'TransferRequest'
		AND a.AlertStatus = 'Open'
		AND transition.TransitionDate IS NULL

	-- transfers in ETS to regions already on NTBS
	INSERT INTO [dbo].[MultiSystemTransfers] ([NotificationID],
		[NotificationDate],
		[SourceSystem],
		[ETSID],
		[Requester],
		[RequestedCaseManager],
		[RequestedOrganisation],
		[CreatedDate])

	SELECT n.LegacyId, n.NotificationDate, 'ETS', NULL, requester.Email, recipient.Email, COALESCE(tbs.Name, userPhec.Name), transfer.AuditCreate
	
	FROM [$(OtherServer)].[$(ETS)].dbo.Transfer transfer
		LEFT JOIN [$(OtherServer)].[$(ETS)].dbo.Notification n ON n.Id = transfer.NotificationId
		LEFT JOIN [$(OtherServer)].[$(ETS)].dbo.SystemUser recipient ON recipient.Id = transfer.RecipientId
		LEFT JOIN [$(OtherServer)].[$(ETS)].dbo.SystemUser requester ON requester.Id = transfer.AuditUserId
		LEFT JOIN [dbo].vwEtsUserPermissionMembership etsPerm ON etsPerm.Username = recipient.Username
		LEFT JOIN [$(NTBS)].ReferenceData.TbService tbs ON tbs.Code = etsPerm.MembershipCode
		LEFT JOIN [$(NTBS)].ReferenceData.PHEC userPhec ON userPhec.Code = etsPerm.MembershipCode
		LEFT JOIN [dbo].NtbsTransitionDateLookup transition ON transition.PHEC = COALESCE(tbs.PHECCode, userPhec.Code)
	WHERE
		transfer.AuditDelete IS NULL
		AND transition.TransitionDate IS NOT NULL
		AND transfer.AuditCreate > transition.TransitionDate
END TRY
BEGIN CATCH
	THROW
END CATCH