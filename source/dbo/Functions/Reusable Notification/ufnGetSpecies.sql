/***************************************************************************************************
Desc:    This re/calculates the value for the data point ReusableNotification.Species
         for each notification record (every night when the uspGenerate schedule runs).
		 The inline comments no 1, 2, 3 ... below have been copied across from the NTBS R1
		 specification in Confluence, and are to be kept in sync with that specification.


         
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnGetSpecies] (
	@NotificationId int
)
	RETURNS VARCHAR(50)
AS
	BEGIN
		DECLARE @ReturnValue AS NVARCHAR(50) = NULL

		-- 1. The notification has no Anonymised records
		IF (@ReturnValue IS NULL)
		BEGIN
			IF NOT EXISTS (SELECT TOP 1 ''
							FROM dbo.StandardisedETSLaboratoryResult l
								INNER JOIN [$(Labbase2)].dbo.Anonymised a ON a.OpieId = l.OpieId
							WHERE l.NotificationId = @NotificationId)
			SET @ReturnValue = ''
		END

		-- 2. The notification has one Anonymised record
		-- 3. The notification has more than one Anonymised record
		IF (@ReturnValue IS NULL)
		BEGIN
			SET @ReturnValue = (SELECT TOP 1 o.OrganismName
								FROM Organism o
									INNER JOIN OrganismNameMapping om ON om.OrganismId = o.OrganismId
									INNER JOIN [$(Labbase2)].dbo.Anonymised a ON RTRIM(a.OrganismName) = om.OrganismName
									INNER JOIN [dbo].[StandardisedETSLaboratoryResult] l ON l.OpieId = a.OpieId
								WHERE l.NotificationId = @NotificationId
								ORDER BY o.OrganismId) -- Order by ID means: Order by organism severity
		END

		-- 4. An error has occurred
		IF (@ReturnValue IS NULL)
		BEGIN
			SET @ReturnValue = 'Error: Invalid value'
		END

		RETURN @ReturnValue
	END
