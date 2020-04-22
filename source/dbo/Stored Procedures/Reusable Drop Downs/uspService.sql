/***************************************************************************************************
Desc:    This returns the permission- and region-filtered Services for an AD group user.

Author:  Public Health England
         Adil Mirza    <adil.mirza@phe.gov.uk>
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspService] 
	@Region VARCHAR(100) = 'AllowAll' -- The region to narrow down services by. 
	-- The AllowAll default value means we can move reports to use this one by one, rathar than updating them all at once.
	-- The default value (and the condition it satisfies below) can be removed once all service user reports are merged into their base counterparts
AS
	SET NOCOUNT ON

	BEGIN TRY
		DECLARE	@LoginGroups VARCHAR(500)
		EXEC dbo.uspGetAuthenticatedLoginGroups @LoginGroups OUTPUT

		DECLARE	@UserType VARCHAR(1)
		SELECT @UserType = ADGroupType
		FROM AdGroup
		WHERE CHARINDEX('###' + AdGroupName + '###', @LoginGroups) != 0

		-- Debugging
		-- EXEC master..xp_logevent 60000, @LoginGroups

		IF (@LoginGroups != '###')
		BEGIN
			IF (@UserType = 'S') 
				-- service user, restrict by selected region and by user access to services
				SELECT distinct 
					s.Serviceid,
					TB_Service_Name
				FROM dbo.TB_Service s
					INNER JOIN dbo.ServiceAdGroup sad ON sad.ServiceId = s.Serviceid
					INNER JOIN dbo.AdGroup agt ON agt.AdGroupId = sad.AdGroupId
				WHERE PhecName != 'Unknown'
					AND (@Region = 'AllowAll' OR PhecName = @Region)
					AND CHARINDEX('###' + agt.AdGroupName + '###', @LoginGroups) != 0
					order by TB_Service_Name
			ELSE IF (@UserType = 'R' OR @UserType = 'N') 
				-- regional user or national team user, only restrict by selected region
				SELECT Serviceid,TB_Service_Name 
				FROM dbo.TB_Service s
				WHERE PhecName = @Region
			ELSE
				RAISERROR ('This user does not have a recognized user type', 16, 1) WITH NOWAIT
		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
GO
