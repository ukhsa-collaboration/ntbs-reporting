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


CREATE PROCEDURE [dbo].[uspGenerateReportingLegacyTreatmentRegimen]

AS
BEGIN TRY
	UPDATE le
		SET ShortCourse = 'Yes', MDRTreatment = 'No'
	FROM [dbo].[Record_LegacyExtract] le
		INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = le.NotificationId
	WHERE le.NotificationId IN (SELECT NotificationId FROM [$(NTBS)].dbo.ClinicalDetails WHERE TreatmentRegimen = 'StandardTherapy')
	AND rr.SourceSystem = 'NTBS'


	UPDATE le
		SET ShortCourse = 'No', MDRTreatment = 'Yes'
	FROM [dbo].[Record_LegacyExtract] le
		INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = le.NotificationId
	WHERE le.NotificationId IN (SELECT NotificationId FROM [$(NTBS)].dbo.ClinicalDetails WHERE TreatmentRegimen = 'MdrTreatment')
	AND rr.SourceSystem = 'NTBS'

	UPDATE le
		SET ShortCourse = 'No', MdrTreatment = 'No'
	FROM [dbo].[Record_LegacyExtract] le
		INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = le.NotificationId
	WHERE le.NotificationId IN (SELECT NotificationId FROM [$(NTBS)].dbo.ClinicalDetails WHERE TreatmentRegimen = 'Other')
	AND rr.SourceSystem = 'NTBS'
END TRY
BEGIN CATCH
	THROW
END CATCH