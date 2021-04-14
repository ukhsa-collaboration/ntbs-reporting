/*This is a lookup table out output values for the DOTReceived field.
It supports the ETS 'On DOT' field using the same logic as applies in the migration database
where No is not mapped because 'not on DOT' does not equate to DOT offered/DOT refused.
It also outputs the display values for NTBS which are defined here: 
https://github.com/publichealthengland/ntbs_Beta/blob/master/ntbs-service/Models/Enums/DotStatus.cs
*/



CREATE PROCEDURE [dbo].[uspPopulateLookupTables]
AS
BEGIN TRY
	TRUNCATE TABLE [dbo].[DOTLookup]
	INSERT INTO [dbo].[DOTLookup](SystemValue, DOTOffered, DOTReceived)
	VALUES
	--ETS values
	('1', 'Yes', 'DOT received'),
	('0', NULL, NULL),
	('2', 'Unknown', 'Unknown'),
	--NTBS values - IsDotOffered doesn't require translation for the reporting service
	('DotReceived', NULL, 'DOT received'),
	('DotRefused', NULL, 'DOT refused'),
	('Unknown', NULL, 'Unknown')


END TRY
BEGIN CATCH
	THROW
END CATCH

RETURN 0
