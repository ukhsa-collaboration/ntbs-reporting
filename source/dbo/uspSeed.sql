﻿
/***************************************************************************************************
Desc:    This seeds or re-seeds the look-up-data. It gets called from uspGenerate(),
		 so is run straight after every code deployment. If in doubt, you can also
		 run this proc stand-alone at any time, and it will re-seed the look-up data.



**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspSeed] AS
	BEGIN TRY
		-- If any errors, then roll back
		BEGIN TRANSACTION

		-- If the calendar has not been populated, do so
		IF NOT EXISTS (SELECT 1 FROM [dbo].[Calendar])
		BEGIN
			EXEC uspPopulateCalendarTable
		END

		-- If the feature flags have not been set, set them
		-- These include or exclude records from various datasources in the reporting database
		IF NOT EXISTS (SELECT 1 FROM [dbo].[ReportingFeatureFlags])
		BEGIN
			INSERT INTO [dbo].[ReportingFeatureFlags](IncludeNTBS, IncludeETS, IncludeLabBase, Comment)
			VALUES(1, 1, 1, 'Include or exclude records from various datasources in the reporting database')
		END

		-- Disable all foreign keys to make the inserts below succeedC:\Users\ntbsadmin\Desktop\phe-ntbs-summaries\visual-studio\dbo\uspDeploy.sql
		DECLARE @SqlNocheck NVARCHAR(MAX) = ''
		;WITH x AS
		(
			SELECT DISTINCT obj =
				QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' +
				QUOTENAME(OBJECT_NAME(parent_object_id))
			FROM sys.foreign_keys
		)
		SELECT @SqlNocheck += N'ALTER TABLE ' + obj + ' NOCHECK CONSTRAINT ALL;' FROM x;
		EXEC sp_executesql @SqlNocheck;

		-- Permission inserts
		DELETE FROM dbo.Phec
		SET IDENTITY_INSERT [dbo].[Phec] ON
		INSERT dbo.Phec (PhecId, PhecCode, PhecName, SortOrder) VALUES (1, N'E45000001', N'London', 3)
		INSERT dbo.Phec (PhecId, PhecCode, PhecName, SortOrder) VALUES (2, N'E45000010', N'Yorkshire and Humber', 9)
		INSERT dbo.Phec (PhecId, PhecCode, PhecName, SortOrder) VALUES (3, N'E45000016', N'East Midlands', 1)
		INSERT dbo.Phec (PhecId, PhecCode, PhecName, SortOrder) VALUES (4, N'E45000005', N'West Midlands', 8)
		INSERT dbo.Phec (PhecId, PhecCode, PhecName, SortOrder) VALUES (5, N'E45000019', N'South East', 6)
		INSERT dbo.Phec (PhecId, PhecCode, PhecName, SortOrder) VALUES (6, N'E45000020', N'South West', 7)
		INSERT dbo.Phec (PhecId, PhecCode, PhecName, SortOrder) VALUES (7, N'E45000017', N'East of England', 2)
		INSERT dbo.Phec (PhecId, PhecCode, PhecName, SortOrder) VALUES (8, N'E45000009', N'North East', 4)
		INSERT dbo.Phec (PhecId, PhecCode, PhecName, SortOrder) VALUES (9, N'E45000018', N'North West', 5)
		INSERT dbo.Phec (PhecId, PhecCode, PhecName, SortOrder) VALUES (10, N'Unknown', N'Unknown', 10)
		INSERT dbo.Phec (PhecId, PhecCode, PhecName, SortOrder) VALUES (11, N'PHECWAL', N'Wales', 11)
		INSERT dbo.Phec (PhecId, PhecCode, PhecName, SortOrder) VALUES (12, N'PHECNI', N'Northern Ireland', 12)
		SET IDENTITY_INSERT [dbo].[Phec] OFF

		DELETE FROM dbo.AdGroup
		SET IDENTITY_INSERT [dbo].[AdGroup] ON
		INSERT [dbo].[AdGroup] ([AdGroupId], [AdGroupName], [IsNationalTeam],[ADGroupType]) VALUES (1, N'Global.NIS.NTBS.LON', 0,'R')
		INSERT [dbo].[AdGroup] ([AdGroupId], [AdGroupName], [IsNationalTeam],[ADGroupType]) VALUES (2, N'Global.NIS.NTBS.YHR', 0,'R')
		INSERT [dbo].[AdGroup] ([AdGroupId], [AdGroupName], [IsNationalTeam],[ADGroupType]) VALUES (3, N'Global.NIS.NTBS.EMS', 0,'R')
		INSERT [dbo].[AdGroup] ([AdGroupId], [AdGroupName], [IsNationalTeam],[ADGroupType]) VALUES (4, N'Global.NIS.NTBS.WMS', 0,'R')
		INSERT [dbo].[AdGroup] ([AdGroupId], [AdGroupName], [IsNationalTeam],[ADGroupType]) VALUES (5, N'Global.NIS.NTBS.SoE', 0,'R')
		INSERT [dbo].[AdGroup] ([AdGroupId], [AdGroupName], [IsNationalTeam],[ADGroupType]) VALUES (6, N'Global.NIS.NTBS.SoW', 0,'R')
		INSERT [dbo].[AdGroup] ([AdGroupId], [AdGroupName], [IsNationalTeam],[ADGroupType]) VALUES (7, N'Global.NIS.NTBS.EoE', 0,'R')
		INSERT [dbo].[AdGroup] ([AdGroupId], [AdGroupName], [IsNationalTeam],[ADGroupType]) VALUES (8, N'Global.NIS.NTBS.NoE', 0,'R')
		INSERT [dbo].[AdGroup] ([AdGroupId], [AdGroupName], [IsNationalTeam],[ADGroupType]) VALUES (9, N'Global.NIS.NTBS.NoW', 0,'R')
		INSERT [dbo].[AdGroup] ([AdGroupId], [AdGroupName], [IsNationalTeam],[ADGroupType]) VALUES (10, N'Global.NIS.NTBS.NTS', 1,'N')
		INSERT [dbo].[AdGroup] ([AdGroupId], [AdGroupName], [IsNationalTeam],[ADGroupType]) VALUES (11, N'Global.NIS.NTBS.TestGroup1', 0,'S')
		INSERT [dbo].[AdGroup] ([AdGroupId], [AdGroupName], [IsNationalTeam],[ADGroupType]) VALUES (12, N'Global.NIS.NTBS.TestGroup2', 0,'S')
		INSERT [dbo].[AdGroup] ([AdGroupId], [AdGroupName], [IsNationalTeam],[ADGroupType]) VALUES (13, N'Global.NIS.NTBS.WALES', 0, 'R')
		INSERT [dbo].[AdGroup] ([AdGroupId], [AdGroupName], [IsNationalTeam],[ADGroupType]) VALUES (14, N'Global.NIS.NTBS.NI', 0, 'R')
		SET IDENTITY_INSERT [dbo].[AdGroup] OFF

		DELETE FROM dbo.PhecAdGroup
		SET IDENTITY_INSERT [dbo].[PhecAdGroup] ON
		INSERT [dbo].[PhecAdGroup] ([PhecAdGroupId], [PhecId], [AdGroupId]) VALUES (1, 1, 1)
		INSERT [dbo].[PhecAdGroup] ([PhecAdGroupId], [PhecId], [AdGroupId]) VALUES (2, 2, 2)
		INSERT [dbo].[PhecAdGroup] ([PhecAdGroupId], [PhecId], [AdGroupId]) VALUES (3, 3, 3)
		INSERT [dbo].[PhecAdGroup] ([PhecAdGroupId], [PhecId], [AdGroupId]) VALUES (4, 4, 4)
		INSERT [dbo].[PhecAdGroup] ([PhecAdGroupId], [PhecId], [AdGroupId]) VALUES (5, 5, 5)
		INSERT [dbo].[PhecAdGroup] ([PhecAdGroupId], [PhecId], [AdGroupId]) VALUES (6, 6, 6)
		INSERT [dbo].[PhecAdGroup] ([PhecAdGroupId], [PhecId], [AdGroupId]) VALUES (7, 7, 7)
		INSERT [dbo].[PhecAdGroup] ([PhecAdGroupId], [PhecId], [AdGroupId]) VALUES (8, 8, 8)
		INSERT [dbo].[PhecAdGroup] ([PhecAdGroupId], [PhecId], [AdGroupId]) VALUES (9, 9, 9)
		INSERT [dbo].[PhecAdGroup] ([PhecAdGroupId], [PhecId], [AdGroupId]) VALUES (10, 1, 10)
		INSERT [dbo].[PhecAdGroup] ([PhecAdGroupId], [PhecId], [AdGroupId]) VALUES (11, 2, 10)
		INSERT [dbo].[PhecAdGroup] ([PhecAdGroupId], [PhecId], [AdGroupId]) VALUES (12, 3, 10)
		INSERT [dbo].[PhecAdGroup] ([PhecAdGroupId], [PhecId], [AdGroupId]) VALUES (13, 4, 10)
		INSERT [dbo].[PhecAdGroup] ([PhecAdGroupId], [PhecId], [AdGroupId]) VALUES (14, 5, 10)
		INSERT [dbo].[PhecAdGroup] ([PhecAdGroupId], [PhecId], [AdGroupId]) VALUES (15, 6, 10)
		INSERT [dbo].[PhecAdGroup] ([PhecAdGroupId], [PhecId], [AdGroupId]) VALUES (16, 7, 10)
		INSERT [dbo].[PhecAdGroup] ([PhecAdGroupId], [PhecId], [AdGroupId]) VALUES (17, 8, 10)
		INSERT [dbo].[PhecAdGroup] ([PhecAdGroupId], [PhecId], [AdGroupId]) VALUES (18, 9, 10)
		INSERT [dbo].[PhecAdGroup] ([PhecAdGroupId], [PhecId], [AdGroupId]) VALUES (19, 10, 10)
		INSERT [dbo].[PhecAdGroup] ([PhecAdGroupId], [PhecId], [AdGroupId]) VALUES (20, 11, 13)
		INSERT [dbo].[PhecAdGroup] ([PhecAdGroupId], [PhecId], [AdGroupId]) VALUES (21, 12, 14)
		SET IDENTITY_INSERT [dbo].[PhecAdGroup] OFF

		-- Other inserts
		TRUNCATE TABLE [dbo].[TemplateText]
		INSERT INTO [dbo].[TemplateText]([Desc],[Text])
		VALUES
			('Footer text to be displayed in each report',
			'1.1. The source ETS data presented are correct as at {ETS_LAST_REFRESHED}. 
			1.2. The source NTBS data presented are correct as at {NTBS_LAST_REFRESHED}. 
			1.3 The source Cluster data presented are correct as at {CLUSTER_LAST_REFRESHED} .
			1.4 The data presented in this report was generated at {REPORTING_LAST_REFRESHED}.
			2. The data presented are provisional and are subject to change.
			3. Source: Reporting Service, Enhanced Tuberculosis Surveillance system (ETS) AND National TB Surveillance system (NTBS). Use of data is covered by ETS and NTBS Data Access and Provision Policies
			Reporting version: Release-{REPORTING_RELEASE_VERSION}-{REPORTING_RELEASE_DATE}')


		DELETE FROM [dbo].[OutcomeLookup]
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('Completed', 'Completed')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('Cured', 'Cured')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('Died', 'Died')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('Lost', 'Lost to follow-up')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('NotEvaluated', 'Not evaluated')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('TreatmentStopped', 'Treatment stopped')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('Failed', 'Failed')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('AdditionalResistance', 'Additional resistance')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('AdverseReaction', 'Adverse reaction')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('CulturePositive', 'Culture positive')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('MdrRegimen', 'Multi-drug resistant regimen')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('Other', 'Other')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('PatientLeftUk', 'Patient left UK')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('PatientNotLeftUk', 'Patient has not left UK')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('StandardTherapy', 'Standard therapy')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('StillOnTreatment', 'Still on treatment')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('TbCausedDeath', 'TB caused death')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('TbContributedToDeath', 'TB contributed to death')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('TbIncidentalToDeath', 'TB was incidental to death')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('TransferredAbroad', 'Transferred abroad')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('Unknown', 'Unknown')


		DELETE FROM [dbo].[DenotificationReasonMapping]
		INSERT [dbo].[DenotificationReasonMapping] (Reason, ReasonOutputName) VALUES ('DuplicateEntry', 'Duplicate entry')
		INSERT [dbo].[DenotificationReasonMapping] (Reason, ReasonOutputName) VALUES ('DuplicateEpisode', 'Duplicate episode (episodes less than 12 months apart)')
		INSERT [dbo].[DenotificationReasonMapping] (Reason, ReasonOutputName) VALUES ('NotTbAtypicalMyco', 'Patient found not to have TB (atypical mycobacteria)')
		INSERT [dbo].[DenotificationReasonMapping] (Reason, ReasonOutputName) VALUES ('NotTbOther', 'Patient found not to have TB (other)')
		INSERT [dbo].[DenotificationReasonMapping] (Reason, ReasonOutputName) VALUES ('Other', 'Other')

		DELETE FROM [dbo].[LegacySiteMapping]
		INSERT [dbo].[LegacySiteMapping] (SiteId, SiteOutputName) VALUES (1, 'SitePulmonary')
		INSERT [dbo].[LegacySiteMapping] (SiteId, SiteOutputName) VALUES (2, 'SiteBoneSpine')
		INSERT [dbo].[LegacySiteMapping] (SiteId, SiteOutputName) VALUES (3, 'SiteBoneOther')
		INSERT [dbo].[LegacySiteMapping] (SiteId, SiteOutputName) VALUES (4, 'SiteCNSMeningitis')
		INSERT [dbo].[LegacySiteMapping] (SiteId, SiteOutputName) VALUES (5, 'SiteCNSOther')
		INSERT [dbo].[LegacySiteMapping] (SiteId, SiteOutputName) VALUES (6, 'SiteNonPulmonaryOther')
		INSERT [dbo].[LegacySiteMapping] (SiteId, SiteOutputName) VALUES (7, 'SiteCryptic')
		INSERT [dbo].[LegacySiteMapping] (SiteId, SiteOutputName) VALUES (8, 'SiteGI')
		INSERT [dbo].[LegacySiteMapping] (SiteId, SiteOutputName) VALUES (9, 'SiteGU')
		INSERT [dbo].[LegacySiteMapping] (SiteId, SiteOutputName) VALUES (10, 'SiteITLymphNodes')
		INSERT [dbo].[LegacySiteMapping] (SiteId, SiteOutputName) VALUES (11, 'SiteLymphNode')
		INSERT [dbo].[LegacySiteMapping] (SiteId, SiteOutputName) VALUES (12, 'SiteLaryngeal')
		INSERT [dbo].[LegacySiteMapping] (SiteId, SiteOutputName) VALUES (13, 'SiteMiliary')
		INSERT [dbo].[LegacySiteMapping] (SiteId, SiteOutputName) VALUES (14, 'SitePleural')
		INSERT [dbo].[LegacySiteMapping] (SiteId, SiteOutputName) VALUES (15, 'SiteNonPulmonaryOther')
		INSERT [dbo].[LegacySiteMapping] (SiteId, SiteOutputName) VALUES (16, 'SiteNonPulmonaryOther')
		INSERT [dbo].[LegacySiteMapping] (SiteId, SiteOutputName) VALUES (17, 'SiteNonPulmonaryOther')

		DELETE FROM [dbo].[DeathLookup]
		INSERT [dbo].[DeathLookup] (DeathCode, DeathDescription) VALUES ('TbCausedDeath', 'TB caused death')
		INSERT [dbo].[DeathLookup] (DeathCode, DeathDescription) VALUES ('TbContributedToDeath', 'TB contributed to death')
		INSERT [dbo].[DeathLookup] (DeathCode, DeathDescription) VALUES ('TbIncidentalToDeath', 'TB incidental to death')
		INSERT [dbo].[DeathLookup] (DeathCode, DeathDescription) VALUES ('Unknown', 'Unknown')

		DELETE FROM [dbo].[TreatmentRegimenLookup]
		INSERT [dbo].[TreatmentRegimenLookup] (TreatmentRegimenCode, TreatmentRegimenDescription) VALUES ('StandardTherapy', 'Standard therapy')
		INSERT [dbo].[TreatmentRegimenLookup] (TreatmentRegimenCode, TreatmentRegimenDescription) VALUES ('MdrTreatment', 'RR/MDR/XDR treatment')
		INSERT [dbo].[TreatmentRegimenLookup] (TreatmentRegimenCode, TreatmentRegimenDescription) VALUES ('Other', 'Other')

		DELETE FROM [dbo].EtsManualTestResultLookup
		INSERT [dbo].EtsManualTestResultLookup (EtsResult, ResultString, Ranking) VALUES (0, 'Negative', 2)
		INSERT [dbo].EtsManualTestResultLookup (EtsResult, ResultString, Ranking) VALUES (1, 'Positive', 1)
		INSERT [dbo].EtsManualTestResultLookup (EtsResult, ResultString, Ranking) VALUES (2, 'Awaiting', 3)
		INSERT [dbo].EtsManualTestResultLookup (EtsResult, ResultString, Ranking) VALUES (3, 'Awaiting', 3)

		EXEC [dbo].[uspSeedHospitalLookupValues]


		-- Enable all foreign keys again
		DECLARE @SqlCheck NVARCHAR(MAX) = '';
		;WITH x AS
		(
			SELECT DISTINCT obj =
				QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' +
				QUOTENAME(OBJECT_NAME(parent_object_id))
			FROM sys.foreign_keys
		)
		SELECT @SqlCheck += N'ALTER TABLE ' + obj + ' WITH CHECK CHECK CONSTRAINT ALL;' FROM x;
		EXEC sp_executesql @SqlCheck;

		COMMIT
	END TRY
	BEGIN CATCH
		-- A "Generate" proc has errored
		ROLLBACK

		-- Show error on screen
		EXEC dbo.uspHandleException
	END CATCH