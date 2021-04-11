CREATE TABLE [dbo].[Record_CaseData](
	
	[CaseDataId] [int] IDENTITY(1,1) NOT NULL,

	-- Global (ETS, LTBR, NTBS encompassing) primary key
	[NotificationId] [int] NOT NULL,
	[EtsId] [bigint] NULL,
	[LtbrId] [varchar](20) NULL,
	[LinkedNotifications] [varchar](200) NULL,
	
	[CaseManager] [nvarchar](101) NULL,
	[Consultant] [nvarchar](255) NULL,
	[HospitalId] [varchar](36) NULL,
	[Hospital] [nvarchar](255) NULL,
	[TbService] [nvarchar](150) NULL,
	[Age] [tinyint] NULL,
	[Sex] [varchar](10) NULL,
	[UkBorn] [varchar](10) null,
	[EthnicGroup] [varchar](255) NULL,
	[Occupation] [nvarchar](255) NULL,
	[OccupationCategory] [varchar] (255) NULL,
	[BirthCountry] [varchar](255) NULL,
	[UkEntryYear] [int] NULL,
	[NoFixedAbode] [varchar](10) NULL,

	-- Geographies
	[LocalAuthority] [varchar](50) NULL,
	[ResidencePhec] [varchar](50) NULL,
	[TreatmentPhec] [varchar](50) NULL,
	[Lat] [nvarchar](50) NULL,
	[Long] [nvarchar](50) NULL,

	-- Clinical Details
	[Symptomatic] [varchar](10) NULL,
	[SymptomOnsetDate] date NULL,
	[FirstPresentationDate] date NULL,
	[OnsetToFirstPresentationDays] INT NULL,
	[TbServicePresentationDate] date NULL,
	[FirstPresentationToTbServicePresentationDays] INT NULL,
	[DiagnosisDate] date NULL,
	[PresentationToDiagnosisDays] INT NULL,
	[StartOfTreatmentDate] date NULL,
	[DiagnosisToTreatmentDays] INT NULL,
	[OnsetToTreatmentDays] INT NULL,
	[HivTestOffered] [varchar](30) NULL,
	[SiteOfDisease] [varchar](50) NULL,
	[PostMortemDiagnosis] [varchar](10) NULL,
	[DidNotStartTreatment] [varchar](10) NULL,
	[TreatmentRegimen] [nvarchar](30) NULL,
	[MdrTreatmentDate] date NULL,
	[EnhancedCaseManagement] [varchar] (10) NULL,
	[EnhancedCaseManagementLevel] [nvarchar] (10) NULL,
	[DOTOffered] [varchar] (10) NULL,
	[DOTReceived] [varchar] (20) NULL,
	[TestPerformed] [varchar] (10) NULL,
	[ChestXRayResult] [nvarchar] (100) NULL,

	--outcomes
	[TreatmentOutcome12months] [varchar](30) NULL,
	[TreatmentOutcome24months] [varchar](30) NULL,
	[TreatmentOutcome36months] [varchar](30) NULL,
	[LastRecordedTreatmentOutcome] [varchar](30) NULL,
	[DateOfDeath] DATE NULL,
	[TreatmentEndDate] date NULL,


	--contact tracing
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
	--previous notification
	[PreviouslyDiagnosed] [varchar](10) NULL,
	[YearsSinceDiagnosis] INT NULL,
	[PreviouslyTreated] [varchar](10) NULL,
	[TreatmentInUk] [varchar](10) NULL,
	[PreviousId] [varchar](50) NULL,
	[BcgVaccinated] [varchar](10) NULL,

	-- Risk Factors
	[AnySocialRiskFactor] [varchar](10) NULL,
	[AlcoholMisuse] [varchar](10) NULL,
	[DrugMisuse] [varchar](10) NULL,
	[CurrentDrugMisuse] [varchar](10) NULL,
	[DrugMisuseInLast5Years] [varchar](10) NULL,
	[DrugMisuseMoreThan5YearsAgo] [varchar](10) NULL,
	[Homeless] [varchar](10) NULL,
	[CurrentlyHomeless] [varchar](10) NULL,
	[HomelessInLast5Years] [varchar](10) NULL,
	[HomelessMoreThan5YearsAgo] [varchar](10) NULL,
	[Prison] [varchar](10) NULL,
	[CurrentlyInPrisonOrInPrisonWhenFirstSeen] [varchar](10) NULL,
	[InPrisonInLast5Years] [varchar](10) NULL,
	[InPrisonMoreThan5YearsAgo] [varchar](10) NULL,
	[Smoking] [varchar](10) NULL,
	[CurrentSmoker] [varchar](10) NULL,
	[SmokerInLast5Years] [varchar](10) NULL,
	[SmokerMoreThan5YearsAgo] [varchar](10) NULL,
	[MentalHealth] [varchar](10) NULL,
	[AsylumSeeker] [varchar](10) NULL,
	[ImmigrationDetainee] [varchar](10) NULL,

	--travel and visitor
	[TravelledOutsideUk] [varchar](10) NULL,
	[ToHowManyCountries] [int] NULL,
	[TravelCountry1] [nvarchar](255) NULL,
	[MonthsTravelled1] [int] NULL,
	[TravelCountry2] [nvarchar](255) NULL,
	[MonthsTravelled2] [int] NULL,
	[TravelCountry3] [nvarchar](255) NULL,
	[MonthsTravelled3] [int] NULL,
	[ReceivedVisitors] [varchar](10) NULL,
	[FromHowManyCountries] [int] NULL,
	[VisitorCountry1] [nvarchar](255) NULL,
	[MonthsVisitorsStayed1] [int] NULL,
	[VisitorCountry2] [nvarchar](255) NULL,
	[MonthsVisitorsStayed2] [int] NULL,
	[VisitorCountry3] [nvarchar](255) NULL,
	[MonthsVisitorsStayed3] [int] NULL,
	[Diabetes] [varchar](10)  NULL,
	[HepatitisB] [varchar](10)  NULL,
	[HepatitisC] [varchar](10)  NULL,
	[ChronicLiverDisease] [varchar](10)  NULL,
	[ChronicRenalDisease] [varchar](10)  NULL,
	[ImmunoSuppression] [varchar](10)  NULL,
	[BiologicalTherapy] [varchar](10)  NULL,
	[Transplantation] [varchar](10)  NULL,
	[OtherImmunoSuppression] [varchar](30) NULL,
	
	
	
	
	[DataRefreshedAt] [datetime] NOT NULL

	 CONSTRAINT [PK_CaseDataId] PRIMARY KEY CLUSTERED (
		[CaseDataId] ASC
	) 
) ON [PRIMARY]
GO

