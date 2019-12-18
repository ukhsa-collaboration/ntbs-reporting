﻿/***************************************************************************************************
Desc:    This pre-calculates the figures for the "Data Quality" report for performance reasons
         (this is part of the re-generation schedule every night).


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspGenerateDataQuality] AS
	BEGIN TRY
		SET NOCOUNT ON

				-- Reset
		DELETE FROM dbo.DataQuality

		-- Seed table with all (valid) notifications to consider
		INSERT INTO dbo.DataQuality (NotificationId,TreatmentEndDate)
		SELECT NotificationId,1
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentEndDate is null and LastRecordedTreatmentOutcome = 'Completed'

		INSERT INTO dbo.DataQuality (NotificationId,TreatmentOutcome12Months)
		SELECT NotificationId,1
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE datediff(day, NotificationDate, getdate()) > 365
								  and  TreatmentOutcome12Months in ('Error: Invalid value','Unknown','Not evaluated','')

		INSERT INTO dbo.DataQuality (NotificationId,TreatmentOutcome24Months)
		SELECT NotificationId,1
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE datediff(day, NotificationDate, getdate()) > 730 
								 and  TreatmentOutcome12Months = 'Still on treatment'
										and TreatmentOutcome24Months in ('Error: Invalid value','Unknown','Not evaluated','')			

		INSERT INTO dbo.DataQuality (NotificationId,TreatmentOutcome36Months)
		SELECT NotificationId,1
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE datediff(day, NotificationDate, getdate()) > 1095 
								 and  TreatmentOutcome24Months = 'Still on treatment'
								 and TreatmentOutcome36Months in ('Error: Invalid value','Unknown','Not evaluated','') 	

		INSERT INTO dbo.DataQuality (NotificationId,DateOfDeath)
		SELECT NotificationId,1
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE LastRecordedTreatmentOutcome = 'Died' and DateOfDeath is null

		INSERT INTO dbo.DataQuality (NotificationId,DateOfBirth)
		SELECT NotificationId,1
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE DateOfBirth is null

		INSERT INTO dbo.DataQuality (NotificationId,UKBorn)
		SELECT NotificationId,1
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE UkBorn = 'Unknown'

		INSERT INTO dbo.DataQuality (NotificationId,SiteOfDisease)
		SELECT NotificationId,1
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE SiteOfDisease = 'Unknown'

		INSERT INTO dbo.DataQuality (NotificationId,Denotify)
		SELECT NotificationId,1
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE LastRecordedTreatmentOutcome = 'Patient did not have TB'

		INSERT INTO dbo.DataQuality (NotificationId,OnsetToPresentationDays)
		SELECT NotificationId,1
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE OnsetToPresentationDays <0

		INSERT INTO dbo.DataQuality (NotificationId,PresentationToDiagnosisDays)
		SELECT NotificationId,1
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE PresentationToDiagnosisDays <0

		INSERT INTO dbo.DataQuality (NotificationId,DiagnosisToTreatmentDays)
		SELECT NotificationId,1
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE DiagnosisToTreatmentDays < 0

		INSERT INTO dbo.DataQuality (NotificationId,OnsetToTreatmentDays)
		SELECT NotificationId,1
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE OnsetToTreatmentDays <0

		INSERT INTO dbo.DataQuality (NotificationId,Postcode)
		SELECT distinct NotificationId,1
								 FROM dbo.ReusableNotification n WITH (NOLOCK)
								 INNER JOIN dbo.PostcodeLookup pl ON pl.Pcd2 = n.Postcode
								left outer JOIN [$(NTBS_R1_Geography_Staging)].dbo.Reduced_Postcode_file r ON r.Pcode = pl.Pcd2NoSpaces
								WHERE 
								NoFixedAbode = 'No' and
								 (ResidencePhec is null or ResidencePhec = 'unknown')
								and (Postcode <> '' and r.Pcode is null)
								 
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
