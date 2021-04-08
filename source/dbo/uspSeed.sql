
/***************************************************************************************************
Desc:    This seeds or re-seeds the look-up-data. It gets called from uspGenerate(),
         so is run straight after every code deployment. If in doubt, you can also
		 run this proc stand-alone at any time, and it will re-seed the look-up data.



**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspSeed] AS
	BEGIN TRY
		-- If any errors, then roll back
		BEGIN TRANSACTION

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
		DELETE FROM dbo.Organism
		SET IDENTITY_INSERT [dbo].[Organism] ON
		INSERT [dbo].[Organism] ([OrganismId], [Organism_CD], [OrganismName], [SortOrder]) VALUES (1, N'A1000', N'M. bovis', 2)
		INSERT [dbo].[Organism] ([OrganismId], [Organism_CD], [OrganismName], [SortOrder]) VALUES (2, N'A2000', N'M. africanum', 3)
		INSERT [dbo].[Organism] ([OrganismId], [Organism_CD], [OrganismName], [SortOrder]) VALUES (3, N'A3000', N'M. microti', 4)
		INSERT [dbo].[Organism] ([OrganismId], [Organism_CD], [OrganismName], [SortOrder]) VALUES (4, N'A4000', N'M. tuberculosis', 1)
		INSERT [dbo].[Organism] ([OrganismId], [Organism_CD], [OrganismName], [SortOrder]) VALUES (5, N'A5000', N'M. tuberculosis complex', 5)
		SET IDENTITY_INSERT [dbo].[Organism] OFF

		DELETE FROM dbo.OrganismNameMapping
		SET IDENTITY_INSERT [dbo].[OrganismNameMapping] ON
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (6, N'AFRICANUM', 2)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (7, N'AFRICANUM TYPE I', 2)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (18, N'BOVIS', 1)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (86, N'M. MICROTI', 3)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (110, N'MAFR', 2)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (121, N'MBOV', 1)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (136, N'MICROTI', 3)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (152, N'MMIC', 3)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (169, N'MTBC', 5)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (173, N'MTUB', 4)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (174, N'MTUBC', 5)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (180, N'MYCAFR', 2)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (182, N'MYCBOV', 1)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (217, N'MYCOBACTERIUM AFRICANUM', 2)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (231, N'MYCOBACTERIUM BOVIS', 1)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (300, N'MYCOBACTERIUM MICROTI', 3)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (346, N'MYCOBACTERIUM TUBERCULOSIS', 4)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (347, N'MYCOBACTERIUM TUBERCULOSIS COMPLEX', 5)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (348, N'MYCOBACTERIUM TUBERCULOSIS(IDENTIFIED BY WHOLE GEN', 4)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (349, N'MYCOBACTERIUM TUBERCULOSIS(IDENTIFIED BY WHOLE GENOME SEQUENCING', 4)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (361, N'MYCTUB', 4)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (447, N'TBCD', 4)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (448, N'TBPCR3', 4)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (453, N'TUBERCULOSIS', 4)
		INSERT [dbo].[OrganismNameMapping] ([OrganismNameMappingId], [OrganismName], [OrganismId]) VALUES (454, N'TUBERCULOSIS COMPLEX', 5)
		SET IDENTITY_INSERT [dbo].[OrganismNameMapping] OFF

		TRUNCATE TABLE [dbo].[ReleaseVersion]
		INSERT INTO [dbo].[ReleaseVersion]([Version],[Date])
		VALUES ('pre-release', GETDATE())

		TRUNCATE TABLE [dbo].[TemplateText]
		INSERT INTO [dbo].[TemplateText]([Desc],[Text])
		VALUES
			('Footer text to be displayed in each report',
			'1. The source ETS data presented are correct as at {ETS_LAST_REFRESHED}. The source NTBS data presented are correct as at {NTBS_LAST_REFRESHED} and the data presented in this report was generated at {REPORTING_LAST_REFRESHED}.
			2. The data presented are provisional and are subject to change.
			3. Source: Reporting Service, Enhanced Tuberculosis Surveillance system (ETS) AND National TB Surveillance system (NTBS). Use of data is covered by ETS and NTBS Data Access and Provision Policies
			Report version: Release-{REPORTING_RELEASE_VERSION}-{REPORTING_RELEASE_DATE}')


		EXEC dbo.uspAntibioticMapping

		EXEC dbo.uspSampleMapping

		EXEC dbo.uspResultMapping

		DELETE FROM [dbo].[OutcomeLookup]
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('Completed', 'Completed')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('Cured', 'Cured')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('Died', 'Died')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('Lost', 'Lost to follow-up')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('NotEvaluated', 'Not evaluated')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('TreatmentStopped', 'Treatment stopped')
		INSERT [dbo].[OutcomeLookup] (OutcomeCode, OutcomeDescription) VALUES ('Failed', 'Failed')

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

		DELETE FROM [dbo].[AntibioticLookup]
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('AK','Amikacin')
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('AMINO','Aminoglycoside')
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('AZI','Azithromycin')
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('CAP','Capreomycin')
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('CIP','Ciprofloxacin')
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('CLA','Clarithromycin')
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('CLO','Clofazimine')
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('CYC','Cycloserine')
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('EMB','Ethambutol')
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('ETI','Ethionamide')
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('INH','Isoniazid')
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('KAN','Kanamycin')
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('LZD','Linezolid')
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('MFX','Moxifloxacin')
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('OFX','Ofloxacin')
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('PAS','Para Aminosalicylic Acid')
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('PRO','Prothionamide')
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('PZA','Pyrazinamide')
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('QUIN','Quinolone')
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('RIF','Rifampicin')
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('RB','Rifabutin')
		INSERT [dbo].AntibioticLookup (AntibioticOutputName, AntibioticDescription) VALUES ('STR','Streptomycin')

		DELETE FROM [dbo].[TreatmentRegimenLookup]
		INSERT [dbo].[TreatmentRegimenLookup] (TreatmentRegimenCode, TreatmentRegimenDescription) VALUES ('StandardTherapy', 'Standard therapy')
		INSERT [dbo].[TreatmentRegimenLookup] (TreatmentRegimenCode, TreatmentRegimenDescription) VALUES ('MdrTreatment', 'RR/MDR/XDR treatment')
		INSERT [dbo].[TreatmentRegimenLookup] (TreatmentRegimenCode, TreatmentRegimenDescription) VALUES ('Other', 'Other')

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