/***************************************************************************************************
Desc:    The ETS TreatmentPlanned table contains two fields 'ShortCourse' and 'MDRTreatment'.
There is only one field in ReusableNotification to capture this information, so set this field based
on the values of these two input fields.

The three possible values for ReusableNotification.TreatmentRegimen come from the same field in
NTBS's ClinicalDetails table, and are:

		StandardTherapy,
		MdrTreatment,
		Other
**************************************************************************************************/


CREATE PROCEDURE [dbo].[uspGenerateEtsTreatmentRegimen]

AS
BEGIN TRY
	DECLARE @StandardTreatment NVARCHAR(30), @MdrTreatment NVARCHAR(30), @OtherTreatment NVARCHAR(30)

	SELECT @StandardTreatment = TreatmentRegimenDescription
	FROM TreatmentRegimenLookup
	WHERE TreatmentRegimenCode = 'StandardTherapy'

	SELECT @MdrTreatment = TreatmentRegimenDescription
	FROM TreatmentRegimenLookup
	WHERE TreatmentRegimenCode = 'MdrTreatment'

	SELECT @OtherTreatment = TreatmentRegimenDescription
	FROM TreatmentRegimenLookup
	WHERE TreatmentRegimenCode = 'Other'

	UPDATE cd
	SET
		TreatmentRegimen = @StandardTreatment
	FROM
		dbo.Record_CaseData cd
		INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = cd.NotificationId
	WHERE rr.NotificationId IN (SELECT n.LegacyId
							 FROM [$(ETS)].dbo.[Notification] n
								 INNER JOIN [$(ETS)].dbo.TreatmentPlanned tp ON tp.Id = n.TreatmentPlannedId
							 WHERE tp.ShortCourseTreatment = 1 AND COALESCE(tp.MDRTreatment, 0) <> 1)
	AND rr.SourceSystem = 'ETS'
		

	UPDATE cd
	SET
		TreatmentRegimen = @MdrTreatment
	FROM
		dbo.Record_CaseData cd
		INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = cd.NotificationId
	WHERE rr.NotificationId IN (SELECT n.LegacyId
							 FROM [$(ETS)].dbo.[Notification] n
								 INNER JOIN [$(ETS)].dbo.TreatmentPlanned tp ON tp.Id = n.TreatmentPlannedId
							 WHERE COALESCE(tp.ShortCourseTreatment, 0) <> 1 AND tp.MDRTreatment = 1)
	AND rr.SourceSystem = 'ETS'


	UPDATE cd
	SET
		TreatmentRegimen = @OtherTreatment
	FROM
		dbo.Record_CaseData cd
		INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = cd.NotificationId
	WHERE rr.NotificationId IN (SELECT n.LegacyId
							 FROM [$(ETS)].dbo.Notification n
								 INNER JOIN [$(ETS)].dbo.TreatmentPlanned tp ON tp.Id = n.TreatmentPlannedId
							 WHERE (COALESCE(tp.ShortCourseTreatment, 0) <> 1 AND COALESCE(tp.MDRTreatment, 0) <> 1)
								OR (tp.ShortCourseTreatment  = 1 AND tp.MDRTreatment  = 1))
	AND rr.SourceSystem = 'ETS'

END TRY
BEGIN CATCH
	THROW
END CATCH