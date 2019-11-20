/***************************************************************************************************
Desc:    This proc must get called by EVERY end-user proc (= procs that deliver reports to SSRS).
         It must wrap all data that the end-user proc would normally return. Only then it is
		 guaranteed that the NTBS R1 reports are restricted to the AD group users that were imported
		 into the SQL Server instance (= 9 regional PHEC groups & National Team).
		 This is just the first step! At query run-time then ufnAuthorizedReusableNotification()
		 makes sure that the notifcation records get filtered according to permissions.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspGetAuthenticatedLoginGroups] (
	@LoginGroups VARCHAR(500) = '' OUTPUT
) AS
	BEGIN TRY
		SET NOCOUNT ON

		-- Debugging
		-- DECLARE @LoginGroups AS VARCHAR(500);

		SET @LoginGroups = '###'

		DECLARE @LoggedInUser SYSNAME
		SET @LoggedInUser = SUSER_SNAME()

		-- Temporary login info holder
		DECLARE @LoginInfo LoginInfoType 

		-- Get all paths for a user to authenticate into this sql server instance
		INSERT INTO @LoginInfo
			EXEC master.sys.xp_logininfo
					@acctname = @LoggedInUser,
					@option = 'all'

		-- Regional user
		DECLARE LoginCursor CURSOR LOCAL FOR 
			SELECT RIGHT(permissionpath, (LEN(permissionpath) - CHARINDEX('\', permissionpath)))
			FROM @LoginInfo
			WHERE accountname = @LoggedInUser
				AND permissionpath IS NOT NULL -- Exclude empty/powerful permissions
		OPEN LoginCursor 

		DECLARE @PermissionPath VARCHAR(100)

		FETCH NEXT FROM LoginCursor INTO @PermissionPath

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @LoginGroups = @LoginGroups + @PermissionPath + '###'
			FETCH NEXT FROM LoginCursor INTO @PermissionPath
		END

		-- Debugging
		-- PRINT @LoginGroups

		-- Log, if user not found
		IF (@LoginGroups = '###')
			RAISERROR ('This user is not authorized to log into NTBS Reporting', 16, 1) WITH NOWAIT
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
