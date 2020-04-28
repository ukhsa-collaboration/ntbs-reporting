/***************************************************************************************************
Desc:    This returns the permission-filtered PHEC regions for each Service level AD group user. 
		 TODO NTBS-1003: Remove this proc when all reports are merged.

Author:  Public Health England
         Adil Mirza    <adil.mirza@phe.gov.uk>
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspServicePhec] (
	@Option VARCHAR(100) -- Legacy: This is unused, but can't just remove, cos reports still pass it through
) AS
	SET NOCOUNT ON

	BEGIN TRY
		DECLARE	@LoginGroups VARCHAR(500)
		EXEC dbo.uspGetAuthenticatedLoginGroups @LoginGroups OUTPUT

		-- Debugging
		-- EXEC master..xp_logevent 60000, @LoginGroups

		IF (@LoginGroups != '###')
		BEGIN
			SELECT distinct 
				PhecName
			FROM dbo.TB_Service s
				INNER JOIN dbo.ServiceAdGroup sad ON sad.ServiceId = s.Serviceid
				INNER JOIN dbo.AdGroup agt ON agt.AdGroupId = sad.AdGroupId
			WHERE PhecName != 'Unknown'
				-- Permission restrictions on logged-in treatment region
				AND CHARINDEX('###' + agt.AdGroupName + '###', @LoginGroups) != 0
				order by PhecName

		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
GO
