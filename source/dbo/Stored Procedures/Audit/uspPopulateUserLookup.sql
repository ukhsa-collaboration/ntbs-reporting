CREATE PROCEDURE [dbo].[uspPopulateUserLookup]
	
AS
	/*Get all AD Groups*/
	DECLARE @Iteration Integer = 1
	/*Temporary value for testing*/
	DECLARE @MaxVal Integer = 0

	DECLARE @AdGroupName VARCHAR(50) = 'EMPTY'

	DELETE FROM [dbo].UserLookup

	/*Get the highest numbered AD Group to set the number of iterations*/
	SELECT @MaxVal = max(adgroupid) from AdGroup

	WHILE @Iteration <= @MaxVal  
	BEGIN  
		SET @AdGroupName = (SELECT ag.AdGroupName FROM [AdGroup] ag WHERE ag.AdGroupId = @Iteration)

		SELECT @AdGroupName = CONCAT('PHE\', @AdGroupName)
		INSERT INTO [dbo].UserLookup
		( [ACCOUNTNAME], [TYPE],[PRIVILEGE], [MAPPEDLOGINNAME],[PERMISSIONPATH] )
	
		EXEC [$(master)].sys.XP_LOGININFO @AdGroupName, 'members'
		SET @Iteration += 1  
	END;    


RETURN 0
