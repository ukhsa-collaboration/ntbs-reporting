/***************************************************************************************************
Desc:    This selects the "Earliest speciman date" of the TB notification

Args:    @NotificationId


         
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnGetEarliestSpecimenDate] (
	@NotificationId UNIQUEIDENTIFIER
) RETURNS VARCHAR(50) AS
	--BEGIN TRY
		BEGIN
			DECLARE @ReturnValue AS NVARCHAR(50) = NULL

			-- 1. The notification has one Anonymised record
			-- 2. The notification has more than one Anonymised record
			SET @ReturnValue = (SELECT TOP 1 os.OrganismName
								FROM OrganismStandardName os
									INNER JOIN OrganismNameMapping om ON om.OrganismID = os.OrganismID
									INNER JOIN Labbase2.dbo.Anonymised a ON RTRIM(a.OrganismName) = om.OrganismName -- TODO: Capitalised doesn't matter, cos comparison is case-insensitive
									INNER JOIN [$(ETS)].dbo.LaboratoryResult l ON l.OpieId = a.OpieId
								WHERE l.NotificationId = @NotificationId
								--WHERE l.NotificationId = '536B4F20-5DF2-488F-A6B4-053368F856B6'
								ORDER BY os.OrganismID) -- Order by ID = Order by organism priority

			-- 3. The notification has no Anonymised records
			IF (@ReturnValue IS NULL)
				SET @ReturnValue = (SELECT TOP 1 ''
									FROM [$(ETS)].dbo.LaboratoryResult l
										INNER JOIN Labbase2.dbo.Anonymised a ON a.OpieId = l.OpieId
									WHERE l.NotificationId = @NotificationId)

			-- 4. An error has occurred
			IF (@ReturnValue IS NULL)
				SET @ReturnValue = 'Error: Invalid value'

			RETURN @ReturnValue
		END
	--END TRY
	--BEGIN CATCH
		--THROW
	--END CATCH
