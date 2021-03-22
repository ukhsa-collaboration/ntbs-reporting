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


CREATE PROCEDURE [dbo].[uspGenerateReusableNotificationTreatmentRegimen_ETS]

AS

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

	UPDATE dbo.ReusableNotification_ETS
		SET TreatmentRegimen = @StandardTreatment
	WHERE NotificationId IN (SELECT n.LegacyId
							 FROM [$(ETS)].dbo.Notification n
								 INNER JOIN [$(ETS)].dbo.TreatmentPlanned tp ON tp.Id = n.TreatmentPlannedId
							 WHERE tp.ShortCourseTreatment = 1 AND tp.MDRTreatment <> 1)


	UPDATE dbo.ReusableNotification_ETS
		SET TreatmentRegimen = @MdrTreatment
	WHERE NotificationId IN (SELECT n.LegacyId
							 FROM [$(ETS)].dbo.Notification n
								 INNER JOIN [$(ETS)].dbo.TreatmentPlanned tp ON tp.Id = n.TreatmentPlannedId
							 WHERE tp.ShortCourseTreatment <> 1 AND tp.MDRTreatment = 1)


	UPDATE dbo.ReusableNotification_ETS
		SET TreatmentRegimen = @OtherTreatment
	WHERE NotificationId IN (SELECT n.LegacyId
							 FROM [$(ETS)].dbo.Notification n
								 INNER JOIN [$(ETS)].dbo.TreatmentPlanned tp ON tp.Id = n.TreatmentPlannedId
							 WHERE (tp.ShortCourseTreatment <> 1 AND tp.MDRTreatment <> 1)
								OR (tp.ShortCourseTreatment  = 1 AND tp.MDRTreatment  = 1))

RETURN 0