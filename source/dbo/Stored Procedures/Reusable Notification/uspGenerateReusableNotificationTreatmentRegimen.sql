/***************************************************************************************************
Desc:	The reusable notification table contains two fields 'ShortCourse' and 'MDRTreatment'.
There is only one field in NTBS to capture this information, so set both fields based on the value
captured there.

ENUM for the NTBS field is stored in TreatmentRegimen.cs in the NTBS code
Values are:

        StandardTherapy,
        MdrTreatment,
        Other
**************************************************************************************************/




CREATE PROCEDURE [dbo].[uspGenerateReusableNotificationTreatmentRegimen]
	
AS

    UPDATE dbo.ReusableNotification
        SET ShortCourse = 'Yes', MdrTreatment = 'No' 
        WHERE NtbsId IN (SELECT NotificationId FROM [$(NTBS)].dbo.ClinicalDetails WHERE TreatmentRegimen = 'StandardTherapy')

    UPDATE dbo.ReusableNotification
        SET ShortCourse = 'No', MdrTreatment = 'Yes' 
        WHERE NtbsId IN (SELECT NotificationId FROM [$(NTBS)].dbo.ClinicalDetails WHERE TreatmentRegimen = 'MdrTreatment')

    UPDATE dbo.ReusableNotification
        SET ShortCourse = 'No', MdrTreatment = 'No' 
        WHERE NtbsId IN (SELECT NotificationId FROM [$(NTBS)].dbo.ClinicalDetails WHERE TreatmentRegimen = 'Other')

	
RETURN 0
