CREATE TABLE [dbo].[ReusableNotification_ETS](
	-- This primary key
	[ReusableNotificationId] [int] IDENTITY(1,1) NOT NULL,

	-- Global (ETS, LTBR, NTBS encompassing) primary key
	[NotificationId] [nvarchar](50) NOT NULL,
	--NTBS primary key
	NtbsId [int] NULL,
	-- ETS primary key
	[EtsId] [bigint] NULL,
	--Source of record
	SourceSystem [nvarchar](50) NOT NULL,
	-- Demographics
	[LtbrId] [nvarchar](50) NULL,
	[NotificationDate] [date] NOT NULL,
	[CaseManager] [nvarchar](101) NULL,
	[Consultant] [nvarchar](255) NULL,
	[HospitalId] [nvarchar](36) NULL,
	[Hospital] [nvarchar](255) NULL,
	[TBServiceCode] [nvarchar] (50) NULL,
	[Service] [nvarchar](150) NULL,
	[NhsNumber] [nvarchar](50) NULL,
	[Forename] [nvarchar](50) NULL,
	[Surname] [nvarchar](50) NULL,
	[DateOfBirth] [date] NULL,
	[Age] [tinyint] NULL,
	[Sex] [varchar](30) NULL,
	[UkBorn] [varchar](30) null,
	[EthnicGroup] [varchar](255) NULL,
	[BirthCountry] [varchar](255) NULL,
	[UkEntryYear] [int] NULL,
	[Postcode] [nvarchar](20) null,
	[NoFixedAbode] [nvarchar](30) NULL,

	-- Geographies
	[LocalAuthority] [nvarchar](50) NULL,
	[LocalAuthorityCode] [nvarchar](50) NULL,
	[ResidencePhecCode] [nvarchar] (50) NULL,
	[ResidencePhec] [nvarchar](50) NULL,
	[TreatmentPhecCode] [nvarchar] (50) NULL,
	[TreatmentPhec] [nvarchar](50) NULL,

	-- Clinical Details
	[SymptomOnsetDate] date NULL,
	[PresentedDate] date NULL,
	[OnsetToPresentationDays] smallint NULL,
	[DiagnosisDate] date NULL,
	[PresentationToDiagnosisDays] smallint NULL,
	[StartOfTreatmentDate] date NULL,
	[DiagnosisToTreatmentDays] smallint NULL,
	[OnsetToTreatmentDays] smallint NULL,
	[HivTestOffered] [nvarchar](255) NULL,
	[SiteOfDisease] [nvarchar](50) NULL,
	[AdultContactsIdentified] [int] NULL,
	[ChildContactsIdentified] [int] NULL,	
	[TotalContactsIdentified] [int] NULL,
	[AdultContactsAssessed] [int] NULL,
	[ChildContactsAssessed] [int] NULL,
	[TotalContactsAssessed] [int] NULL,
	[AdultContactsActiveTB] [int] NULL,
	[ChildContactsActiveTB] [int] NULL,
	[TotalContactsActiveTB] [int] NULL,
	[AdultContactsLTBI] [int] NULL,
	[ChildContactsLTBI] [int] NULL,
	[TotalContactsLTBI] [int] NULL,
	[AdultContactsLTBITreat] [int] NULL,
	[ChildContactsLTBITreat] [int] NULL,
	[TotalContactsLTBITreat] [int] NULL,
	[AdultContactsLTBITreatComplete] [int] NULL,
	[ChildContactsLTBITreatComplete] [int] NULL,
	[TotalContactsLTBITreatComplete] [int] NULL,
	[PreviouslyDiagnosed] [varchar](30) NULL,
	[YearsSinceDiagnosis] [tinyint] NULL,
	[PreviouslyTreated] [varchar](30) NULL,
	[TreatmentInUk] [varchar](30) NULL,
	[PreviousId] [nvarchar](50) NULL,
	[BcgVaccinated] [varchar](30) NULL,

	-- Risk Factors
	[AnySocialRiskFactor] [varchar](40) NULL,
	[AlcoholMisuse] [varchar](30) NULL,
	[DrugMisuse] [varchar](30) NULL,
	[CurrentDrugMisuse] [varchar](30) NULL,
	[DrugMisuseInLast5Years] [varchar](30) NULL,
	[DrugMisuseMoreThan5YearsAgo] [varchar](30) NULL,
	[Homeless] [varchar](30) NULL,
	[CurrentlyHomeless] [varchar](30) NULL,
	[HomelessInLast5Years] [varchar](30) NULL,
	[HomelessMoreThan5YearsAgo] [varchar](30) NULL,
	[Prison] [varchar](30) NULL,
	[CurrentlyInPrisonOrInPrisonWhenFirstSeen] [varchar](30) NULL,
	[InPrisonInLast5Years] [varchar](30) NULL,
	[InPrisonMoreThan5YearsAgo] [varchar](30) NULL,
	[TravelledOutsideUk] [varchar](30) NULL,
	[ToHowManyCountries] [nvarchar](5) NULL,
	[TravelCountry1] [nvarchar](255) NULL,
	[MonthsTravelled1] [int] NULL,
	[TravelCountry2] [nvarchar](255) NULL,
	[MonthsTravelled2] [int] NULL,
	[TravelCountry3] [nvarchar](255) NULL,
	[MonthsTravelled3] [int] NULL,
	[ReceivedVisitors] [varchar](30) NULL,
	[FromHowManyCountries] [nvarchar](5) NULL,
	[VisitorCountry1] [nvarchar](255) NULL,
	[DaysVisitorsStayed1] [nvarchar](50) NULL,
	[VisitorCountry2] [nvarchar](255) NULL,
	[DaysVisitorsStayed2] [nvarchar](50) NULL,
	[VisitorCountry3] [nvarchar](255) NULL,
	[DaysVisitorsStayed3] [nvarchar](50) NULL,
	[Diabetes] [varchar](30) NULL,
	[HepatitisB] [varchar](30) NULL,
	[HepatitisC] [varchar](30) NULL,
	[ChronicLiverDisease] [varchar](30) NULL,
	[ChronicRenalDisease] [varchar](30) NULL,
	[ImmunoSuppression] [varchar](30) NULL,
	[BiologicalTherapy] [varchar](100) NULL,
	[Transplantation] [varchar](30) NULL,
	[OtherImmunoSuppression] [varchar](30) NULL,
	[CurrentSmoker] [varchar](30) NULL,
	[PostMortemDiagnosis] [varchar](30) NULL,
	[DidNotStartTreatment] [varchar](30) NULL,
	[ShortCourse] [varchar](30) NULL,
	[MdrTreatment] [varchar](30) NULL,
	[MdrTreatmentDate] [date] NULL,
	[TreatmentOutcome12months] VARCHAR(30) NULL,
	[TreatmentOutcome24months] VARCHAR(30) NULL,
	[TreatmentOutcome36months] VARCHAR(30) NULL,
	[LastRecordedTreatmentOutcome] VARCHAR(30) NULL,
	[DateOfDeath] DATE NULL,
	[TreatmentEndDate] [date] NULL,

	-- Culture & Resistance
	[NoSampleTaken] [varchar](30) NULL,
	[CulturePositive] [varchar](30) NULL,
	[Species] [varchar](50) NULL,
	[EarliestSpecimenDate] DATE NULL,
	[DrugResistanceProfile] [varchar](30) NULL,
	[INH] [varchar](30) NULL,
	[RIF] [varchar](30) NULL,
	[EMB] [varchar](30) NULL,
	[PZA] [varchar](30) NULL,
	[AMINO] [varchar](30) NULL,
	[QUIN] [varchar](30) NULL,
	[MDR] [varchar](30) NULL,
	[XDR] [varchar](30) NULL,
	[DataRefreshedAt] [datetime] NOT NULL

	 CONSTRAINT [PK_ReusableNotification_ETS] PRIMARY KEY CLUSTERED (
		[ReusableNotificationId] ASC
	)
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_NotificationId ON dbo.ReusableNotification(NotificationId)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_NotificationDate ON dbo.ReusableNotification(NotificationDate)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_Postcode ON dbo.ReusableNotification(Postcode)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_Age ON dbo.ReusableNotification(Age)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_UkBorn ON dbo.ReusableNotification(UkBorn)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_Service ON dbo.ReusableNotification([Service])
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_TBServiceCode ON dbo.ReusableNotification([TBServiceCode])
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_LocalAuthority ON dbo.ReusableNotification(LocalAuthority)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_TreatmentPhec ON dbo.ReusableNotification(TreatmentPhec)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_TreatmentPhecCode ON dbo.ReusableNotification(TreatmentPhecCode)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_ResidencePhec ON dbo.ReusableNotification(ResidencePhec)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_ResidencePhecCode ON dbo.ReusableNotification(ResidencePhecCode)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_AnySocialRiskFactor ON dbo.ReusableNotification(AnySocialRiskFactor)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_AlcoholMisuse ON dbo.ReusableNotification(AlcoholMisuse)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_CurrentDrugMisuse ON dbo.ReusableNotification(CurrentDrugMisuse)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_CurrentlyHomeless ON dbo.ReusableNotification(CurrentlyHomeless)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_CurrentlyInPrisonOrInPrisonWhenFirstSeen ON dbo.ReusableNotification(CurrentlyInPrisonOrInPrisonWhenFirstSeen)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_ChronicLiverDisease ON dbo.ReusableNotification(ChronicLiverDisease)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_ChronicRenalDisease ON dbo.ReusableNotification(ChronicRenalDisease)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_Diabetes ON dbo.ReusableNotification(Diabetes)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_HepatitisB ON dbo.ReusableNotification(HepatitisB)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_HepatitisC ON dbo.ReusableNotification(HepatitisC)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_CurrentSmoker ON dbo.ReusableNotification(CurrentSmoker)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_SiteOfDisease ON dbo.ReusableNotification(SiteOfDisease)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_DrugResistanceProfile ON dbo.ReusableNotification(DrugResistanceProfile)
GO
CREATE NONCLUSTERED INDEX IX_reusableNotification_ETS_Species ON dbo.ReusableNotification(Species)
GO
