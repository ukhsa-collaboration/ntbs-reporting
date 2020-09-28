/***************************************************************************************************
Desc:    This re/calculates the value for the data points ReusableNotification.Service/TreatmentPhec
         for each notification record (every night when the uspGenerate schedule runs).
		 This calculation involves reference data from the JOIN tables below, eg Reduced_Postcode_file.
		 The inline comments no 1, 2, 3 ... below have been copied across from the NTBS R1
		 specification in Confluence, and are to be kept in sync with that specification.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspGenerateReusableTreatment] AS
	SET NOCOUNT ON

	BEGIN TRY
		
		UPDATE n SET
			[Service] = s.TB_Service_Name,
			[TBServiceCode] = s.TB_Service_Code,
			TreatmentPhec = p.PHEC_Name,
			TreatmentPhecCode = p.PHEC_Code
		-- SELECT n.NotificationId -- Debugging
		FROM dbo.ReusableNotification_ETS n WITH (NOLOCK)
			INNER JOIN [$(NTBS_R1_Geography_Staging)].dbo.Hospital h ON h.HospitalId = n.HospitalId
			INNER JOIN [$(NTBS_R1_Geography_Staging)].dbo.TB_Service_to_Hospital sh ON sh.HospitalID = h.HospitalId
			INNER JOIN [$(NTBS_R1_Geography_Staging)].dbo.TB_Service s ON s.TB_Service_Code = sh.TB_Service_Code
			INNER JOIN [$(NTBS_R1_Geography_Staging)].dbo.TB_Service_to_PHEC sp ON sp.TB_Service_Code = sh.TB_Service_Code
			INNER JOIN [$(NTBS_R1_Geography_Staging)].dbo.PHEC p ON p.PHEC_Code = sp.PHEC_Code


		-- 2. Unknown when no matching hospital or service records
		UPDATE n SET
			TreatmentPhec = 'Unknown'
		-- SELECT n.NotificationId -- Debugging
		FROM dbo.ReusableNotification_ETS n WITH (NOLOCK)
			INNER JOIN [$(NTBS_R1_Geography_Staging)].dbo.Hospital h ON h.HospitalId = n.HospitalId
			INNER JOIN [$(NTBS_R1_Geography_Staging)].dbo.TB_Service_to_Hospital sh ON sh.HospitalID = h.HospitalId
			INNER JOIN [$(NTBS_R1_Geography_Staging)].dbo.TB_Service s ON s.TB_Service_Code = sh.TB_Service_Code
			INNER JOIN [$(NTBS_R1_Geography_Staging)].dbo.TB_Service_to_PHEC sp ON sp.TB_Service_Code = sh.TB_Service_Code
			INNER JOIN [$(NTBS_R1_Geography_Staging)].dbo.PHEC p ON p.PHEC_Code = sp.PHEC_Code
		WHERE h.CountryCode IS NULL -- No matching hospital record

		
	END TRY
	BEGIN CATCH
		THROW
	END CATCH