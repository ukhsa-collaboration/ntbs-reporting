﻿/*This is a lookup table out output values for the DOTReceived field.
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

	TRUNCATE TABLE [dbo].[VOTLookup]
	INSERT INTO [dbo].[VOTLookup](SystemValue, VOTOffered, VOTReceived)
	VALUES
	--NTBS values - IsVotOffered doesn't require translation for the reporting service
	('VotReceived', NULL, 'VOT received'),
	('VotRefused', NULL, 'VOT refused'),
	('Unknown', NULL, 'Unknown')

	TRUNCATE TABLE [dbo].[ManualTestResultRanking];
	INSERT INTO [dbo].[ManualTestResultRanking](Rank, SubRank, ResultName, DisplayName)
	VALUES
	(1, 1, 'Positive', 'Positive'),
	(1, 2, 'Negative', 'Negative'),
	(2, NULL, 'NoResultAvailable', 'No result available'),
	(3, NULL, 'Awaiting', 'Awaiting')

	TRUNCATE TABLE [dbo].[ChestTestResultLookup]
	INSERT INTO [dbo].[ChestTestResultLookup](Ranking, Result, FormattedResult)
	VALUES
	--NTBS values
	(1, 'ConsistentWithTbCavities', 'Consistent with TB - cavities'),
	(2, 'ConsistentWithTbOther', 'Consistent with TB - other'),
	(3, 'NotConsistentWithTb', 'Not consistent with TB'),
	(4, 'Awaiting', 'Awaiting')

	TRUNCATE TABLE [dbo].[NtbsTransitionDateLookup]
	INSERT INTO [dbo].[NtbsTransitionDateLookup] (PHEC, TransitionDate)
	VALUES
	('E45000001', '2021-11-29'),
	('E45000005', '2021-12-06'),
	('E45000009', '2021-07-09'),
	('E45000010', '2021-09-27'),
	('E45000016', '2021-09-27'),
	('E45000017', '2021-12-06'),
	('E45000018', '2021-10-25'),
	('E45000019', '2021-09-13'),
	('E45000020', '2021-12-06'),
	('PHECNI', '2021-12-06'),
	('PHECSCOT', NULL),
	('PHECWAL', '2021-07-09')

END TRY
BEGIN CATCH
	THROW
END CATCH

RETURN 0
