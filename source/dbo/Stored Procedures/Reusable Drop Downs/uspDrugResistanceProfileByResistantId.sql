/***************************************************************************************************
Desc:    This returns the associated DrugResistanceProfile drop-down values depending on which
         drop-down values have been selected from the Resistant table.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspDrugResistanceProfileByResistantId] (
	@ResistantId TINYINT = NULL
) AS
	SET NOCOUNT ON

	BEGIN TRY
		IF (@ResistantId IS NOT NULL) 
			SELECT 
				'All' AS DrugResistanceProfile
			UNION
			SELECT 
				DrugResistanceProfile
			FROM dbo.DrugResistanceProfile
			WHERE ResistantId = @ResistantId
		ELSE
			RAISERROR ('You need to pass a @ResistantId', 16, 1) WITH NOWAIT;
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
