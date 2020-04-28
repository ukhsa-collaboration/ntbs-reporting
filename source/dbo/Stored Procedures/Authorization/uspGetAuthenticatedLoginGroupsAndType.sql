/***************************************************************************************************
Desc:    This proc must get called by EVERY end-user proc (= procs that deliver reports to SSRS).
         It must wrap all data that the end-user proc would normally return. Only then it is
		 guaranteed that the NTBS R1 reports are restricted to the AD group users that were imported
		 into the SQL Server instance (= 9 regional PHEC groups & National Team).
		 This is just the first step! At query run-time then ufnAuthorizedReusableNotification()
		 makes sure that the notifcation records get filtered according to permissions.


         
**************************************************************************************************/

CREATE PROCEDURE dbo.uspGetAuthenticatedLoginGroupsAndType (
	@LoginGroups VARCHAR(500) = '' OUTPUT,
	@LoginType VARCHAR(1) = '' OUTPUT
) AS
	BEGIN TRY
		SET NOCOUNT ON

		-- Debugging
		-- DECLARE @LoginGroups AS VARCHAR(500);

		SET @LoginGroups = '###'
		
		SELECT @LoginGroups = CONCAT('###',REPLACE(AdGroups, ',', '###'),'###') from [User]
				WHERE Username = SYSTEM_USER

		-- Debugging
		-- PRINT @LoginGroups

		-- Log, if user not found
		IF (@LoginGroups = '###')
			RAISERROR ('This user is not authorized to log into NTBS Reporting', 16, 1) WITH NOWAIT

		SELECT @LoginType = ADGroupType
		FROM AdGroup
		WHERE CHARINDEX('###' + AdGroupName + '###', @LoginGroups) != 0
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
