/***************************************************************************************************
Desc:    The legacy extract table contains two fields 'ShortCourse' and 'MDRTreatment'.
There is only one field in NTBS, and ReusableNotification to capture this information, so set both
fields based on the value captured there.

ENUM for the NTBS field is stored in TreatmentRegimen.cs in the NTBS code
Values are:

		StandardTherapy,
		MdrTreatment,
		Other
**************************************************************************************************/


CREATE PROCEDURE [dbo].[uspUpdateLegacyTreatmentRegimen]

AS

	UPDATE [dbo].[LegacyExtract]
		SET ShortCourse = 'Yes', MDRTreatment = 'No'
		WHERE NtbsId IN (SELECT NotificationId FROM [$(NTBS)].dbo.ClinicalDetails WHERE TreatmentRegimen = 'StandardTherapy')


	UPDATE [dbo].[LegacyExtract]
		SET ShortCourse = 'No', MDRTreatment = 'Yes'
		WHERE NtbsId IN (SELECT NotificationId FROM [$(NTBS)].dbo.ClinicalDetails WHERE TreatmentRegimen = 'MdrTreatment')

	UPDATE [dbo].[LegacyExtract]
		SET ShortCourse = 'No', MdrTreatment = 'No'
		WHERE NtbsId IN (SELECT NotificationId FROM [$(NTBS)].dbo.ClinicalDetails WHERE TreatmentRegimen = 'Other')


RETURN 0
