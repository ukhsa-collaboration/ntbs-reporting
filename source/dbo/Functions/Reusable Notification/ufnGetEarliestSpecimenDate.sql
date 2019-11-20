/***************************************************************************************************
Desc:    This re/calculates the value for the data point ReusableNotification.EarliestSpecimenDate
         for each notification record (every night when the uspGenerate schedule runs).
		 The inline comments no 1, 2, 3 ... below have been copied across from the NTBS R1
		 specification in Confluence, and are to be kept in sync with that specification.


         
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnGetEarliestSpecimenDate] (
	@NotificationId UNIQUEIDENTIFIER
)
	RETURNS DATE
AS
	BEGIN
		DECLARE @ReturnValue AS DATE = NULL

		-- 1. Set field to the earliest SpecimenDate from the SpecimenResult records for the given notification
		SET @ReturnValue = (SELECT TOP 1 CONVERT(DATE, s.SpecimenDate)
							FROM [$(Labbase2)].dbo.SpecimenResult s
								INNER JOIN [$(Labbase2)].dbo.Anonymised a ON a.LabDataID = s.LabDataID
								INNER JOIN [$(ETS)].dbo.LaboratoryResult l ON l.OpieId = a.OpieId
							WHERE l.NotificationId = @NotificationId
							ORDER BY s.SpecimenDate) -- Order ascending, so the earliest date appears at the top

		-- WARNING: Can not set to 'Error: Invalid value', cos this is a DATE column!

		RETURN @ReturnValue
	END
