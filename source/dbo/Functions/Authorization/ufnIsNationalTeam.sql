/***************************************************************************************************
Desc:    This can be used to restrict specific sections of SQL code, so that they only get executed 
         for when the user is part of the National Team.

**************************************************************************************************/

CREATE FUNCTION dbo.ufnIsNationalTeam (
	@LoginGroups VARCHAR(500)
)
	RETURNS TINYINT
AS
	BEGIN
		DECLARE @ReturnValue AS TINYINT = 0

		SET @ReturnValue = (SELECT IsNationalTeam
							FROM dbo.AdGroup
							WHERE CHARINDEX('###' + AdGroupName + '###', @LoginGroups) != 0)

		RETURN @ReturnValue
	END
