/***************************************************************************************************
Desc:    This returns the permission-filtered PHEC regions for each AD group user. It returns the
         records for both the treatment & residence PHEC regions.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspPhec] (
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
			SELECT 
				PhecCode, 
				PhecName,
				SortOrder
			FROM dbo.Phec pt
				INNER JOIN dbo.PhecAdGroup pat ON pat.PhecId = pt.PhecId
				INNER JOIN dbo.AdGroup agt ON agt.AdGroupId = pat.AdGroupId
			WHERE PhecName != 'Unknown'
				-- Permission restrictions on logged-in treatment region
				AND CHARINDEX('###' + agt.AdGroupName + '###', @LoginGroups) != 0
			UNION
			SELECT
				PhecCode,
				PhecName,
				SortOrder
			FROM dbo.Phec pr
				INNER JOIN dbo.PhecAdGroup par ON par.PhecId = pr.PhecId
				INNER JOIN dbo.AdGroup agr ON agr.AdGroupId = par.AdGroupId
			WHERE PhecName != 'Unknown'
				-- Permission restrictions on logged-in residence region
				AND CHARINDEX('###' + agr.AdGroupName + '###', @LoginGroups) != 0
			ORDER BY SortOrder
		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
