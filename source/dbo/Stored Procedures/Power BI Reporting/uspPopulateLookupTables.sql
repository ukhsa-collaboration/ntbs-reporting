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

	TRUNCATE TABLE [dbo].[ChestXrayResultLookup]
	INSERT INTO [dbo].[ChestXrayResultLookup](Ranking, Result, FormattedResult)
	VALUES
	--NTBS values
	(1, 'ConsistentWithTbCavities', 'Consistent with TB - cavities'),
	(2, 'ConsistentWithTbOther', 'Consistent with TB - other'),
	(3, 'NotConsistentWithTb', 'Not consistent with TB'),
	(4, 'Awaiting', 'Awaiting')

	TRUNCATE TABLE [dbo].[NtbsTransitionDateLookup]
	INSERT INTO [dbo].[NtbsTransitionDateLookup] (PHEC, TransitionDate)
	VALUES
	('E45000001', NULL),
	('E45000005', NULL),
	('E45000009', '2021-07-19'),
	('E45000010', NULL),
	('E45000016', NULL),
	('E45000017', NULL),
	('E45000018', NULL),
	('E45000019', NULL),
	('E45000020', NULL),
	('PHECNI', NULL),
	('PHECSCOT', NULL),
	('PHECWAL', '2021-07-19')

END TRY
BEGIN CATCH
	THROW
END CATCH

RETURN 0
