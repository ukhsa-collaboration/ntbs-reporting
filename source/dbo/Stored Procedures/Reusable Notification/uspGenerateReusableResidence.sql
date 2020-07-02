/***************************************************************************************************
Desc:    This re/calculates the value for the data points ReusableNotification.LocalAuthority/ResidencePhec
         for each notification record (every night when the uspGenerate schedule runs).
		 This calculation involves reference data from the JOIN tables below, eg Reduced_Postcode_file.
		 The inline comments no 1, 2, 3 ... below have been copied across from the NTBS R1
		 specification in Confluence, and are to be kept in sync with that specification.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspGenerateReusableResidence] AS
	SET NOCOUNT ON

	BEGIN TRY
		-- 1. Only include english post codes
		UPDATE n SET
			LocalAuthority = l.LA_Name,
			LocalAuthorityCode = l.LA_Code,
			ResidencePhec = p.PHEC_Name,
			ResidencePhecCode = p.PHEC_Code
		-- SELECT n.NotificationId -- Debugging
		FROM dbo.ReusableNotification_ETS n WITH (NOLOCK)
			INNER JOIN [$(NTBS_R1_Geography_Staging)].dbo.Reduced_Postcode_file r ON r.Pcode = n.Postcode
			INNER JOIN [$(NTBS_R1_Geography_Staging)].dbo.Local_Authority l ON l.LA_Code = r.LA_Code
			INNER JOIN [$(NTBS_R1_Geography_Staging)].dbo.LA_to_PHEC lp ON lp.LA_Code = l.LA_Code
			INNER JOIN [$(NTBS_R1_Geography_Staging)].dbo.PHEC p ON p.PHEC_Code = lp.PHEC_Code
		WHERE r.Country = 'E92000001'

		-- 2. Unknown when no matching postcode
		UPDATE n SET
			ResidencePhec = 'Unknown'
		-- SELECT n.NotificationId -- Debugging
		FROM dbo.ReusableNotification_ETS n WITH (NOLOCK)
			LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].dbo.Reduced_Postcode_file r ON r.Pcode = n.Postcode
		WHERE (r.Country IS NULL or (r.Country = 'E92000001' and r.LA_Code is null)) and ResidencePhec is null
	END TRY
	BEGIN CATCH
		THROW
	END CATCH