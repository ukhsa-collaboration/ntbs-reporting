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

	UPDATE dbo.ReusableNotification_ETS
		SET TreatmentRegimen = 'Standard therapy'
	WHERE NotificationId IN (SELECT n.LegacyId
							 FROM [$(ETS)].dbo.Notification n
								 INNER JOIN [$(ETS)].dbo.TreatmentPlanned tp ON tp.Id = n.TreatmentPlannedId
							 WHERE tp.ShortCourseTreatment = 1 AND tp.MDRTreatment <> 1)


	UPDATE dbo.ReusableNotification_ETS
		SET TreatmentRegimen = 'RR/MDR/XDR treatment'
	WHERE NotificationId IN (SELECT n.LegacyId
							 FROM [$(ETS)].dbo.Notification n
								 INNER JOIN [$(ETS)].dbo.TreatmentPlanned tp ON tp.Id = n.TreatmentPlannedId
							 WHERE tp.ShortCourseTreatment <> 1 AND tp.MDRTreatment = 1)


	UPDATE dbo.ReusableNotification_ETS
		SET TreatmentRegimen = 'Other'
	WHERE NotificationId IN (SELECT n.LegacyId
							 FROM [$(ETS)].dbo.Notification n
								 INNER JOIN [$(ETS)].dbo.TreatmentPlanned tp ON tp.Id = n.TreatmentPlannedId
							 WHERE (tp.ShortCourseTreatment <> 1 AND tp.MDRTreatment <> 1)
								OR (tp.ShortCourseTreatment  = 1 AND tp.MDRTreatment  = 1))

RETURN 0