/***************************************************************************************************
Desc:    This contains the pre-calculated figures for the "Data Quality" report that get
         re-generated every night.


         
**************************************************************************************************/

CREATE TABLE [dbo].[DataQuality] (
	[DataQualityId] [int] IDENTITY(1,1) NOT NULL,
	[NotificationId] NVARCHAR(50) NOT NULL,
	TreatmentEndDate tinyint NOT NULL DEFAULT(0),
	TreatmentOutcome12Months tinyint NOT NULL DEFAULT(0),
	TreatmentOutcome24Months tinyint NOT NULL DEFAULT(0),
	TreatmentOutcome36Months tinyint NOT NULL DEFAULT(0),
	DateOfDeath tinyint NOT NULL DEFAULT(0),
	DateOfBirth tinyint NOT NULL DEFAULT(0),
	UKBorn tinyint NOT NULL DEFAULT(0),
	SiteOfDisease tinyint NOT NULL DEFAULT(0) ,
	Denotify tinyint NOT NULL DEFAULT(0),
	OnsetToPresentationDays tinyint NOT NULL DEFAULT(0),
	PresentationToDiagnosisDays tinyint NOT NULL DEFAULT(0),
	DiagnosisToTreatmentDays tinyint NOT NULL DEFAULT(0),
	OnsetToTreatmentDays tinyint NOT NULL DEFAULT(0),
	Postcode tinyint NOT NULL DEFAULT(0)

	CONSTRAINT [PK_DataQuality] PRIMARY KEY CLUSTERED (
		[DataQualityId] ASC
	)
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_DataQuality_NotificationId ON dbo.DataQuality(NotificationId)
GO
