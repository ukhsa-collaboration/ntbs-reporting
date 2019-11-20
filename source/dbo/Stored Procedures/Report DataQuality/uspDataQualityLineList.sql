/***************************************************************************************************
Desc:    This serves the "Data Quality Line List", which returns every/most notification data point
         in detail, based on the user's permission & filtering preference. Every notification record
		 returned gets audited, whch means a log entry gets added for each user that views a notification.


         
**************************************************************************************************/



CREATE PROCEDURE [dbo].[uspDataQualityLineList]
		(
			@NotificationYearFrom			INTEGER			=	-3,
			@NotificationMonthFrom			INTEGER			=	1,
			@NotificationYearTo				INTEGER			=	0,
			@NotificationMonthTo			INTEGER			=	1,
			@Region							VARCHAR(50)		=	NULL,
			@ServiceName					VARCHAR(150)	=	NULL,
			@Bucket							VARCHAR(50)		=	NULL	
		)
AS
	SET NOCOUNT ON

	--Debugging
	--EXEC master..xp_logevent 60000, @ResidenceTreatment
	--EXEC master..xp_logevent 60000, @Region

	BEGIN TRY
		DECLARE	@LoginGroups VARCHAR(500)
		EXEC dbo.uspGetAuthenticatedLoginGroups @LoginGroups OUTPUT

		IF (@LoginGroups != '###')
		BEGIN

			-- DEBUGGING: the below comments are for setting parameter values for debugging
			/*
				DECLARE @LoginGroups VARCHAR(500), @NotificationYearFrom INTEGER, @NotificationMonthFrom INTEGER, @NotificationYearTo INTEGER, @NotificationMonthTo INTEGER, @Region VARCHAR(50), @LocalAuthority VARCHAR(50), @ServiceName VARCHAR(150), @Bucket VARCHAR(50)
				SET @LoginGroups = '###Global.NIS.NTBS.LON###'
				SET @NotificationYearFrom =	-3
				SET @NotificationMonthFrom	= 1
				SET @NotificationYearTo	= 0
				SET @NotificationMonthTo = 1
				SET @Region	= 'London'
				SET @LocalAuthority	= 'Brent'
				SET @ServiceName = NULL
				SET @Bucket	= 'table total'
			*/

			DECLARE @NotificationYearTypeFrom	VARCHAR(16) = YEAR(DATEADD(YEAR, @NotificationYearFrom, GETDATE()))
            DECLARE @NotificationDateFrom		DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthFrom) + '/01/' + @NotificationYearTypeFrom)

            DECLARE @NotificationYearTypeTo		VARCHAR(16) = YEAR(DATEADD(YEAR, @NotificationYearTo, GETDATE()))
            DECLARE @NotificationDateTo			DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthTo) + '/01/' + @NotificationYearTypeTo)
			SET @NotificationDateTo							= EOMONTH(@NotificationDateTo)

			--Buckets
			DECLARE @TreatmentEndDate INT = NULL
			DECLARE @TreatmentOutcome12Months INT = NULL
			DECLARE @TreatmentOutcome24Months INT = NULL
			DECLARE @TreatmentOutcome36Months INT = NULL
			DECLARE @DateOfDeath INT = NULL
			DECLARE @DateOfBirth INT = NULL
			DECLARE @UKBorn INT = NULL
			DECLARE @SiteOfDisease INT = NULL
			DECLARE @Denotify INT = NULL
			DECLARE @OnsetToPresentationDays INT = NULL
			DECLARE @PresentationToDiagnosisDays INT = NULL
			DECLARE @DiagnosisToTreatmentDays INT = NULL
			DECLARE @OnsetToTreatmentDays INT = NULL
			DECLARE @Postcode INT = NULL
			DECLARE @TableTotal INT = NULL

		

	IF (@Bucket = 'Treatment end date')  SET @TreatmentEndDate = 1
	 IF (@Bucket = '12 month treatment outcome')  SET @TreatmentOutcome12Months = 1
	IF (@Bucket = '24 month treatment outcome')  SET @TreatmentOutcome24Months = 1
	IF (@Bucket = '36 month treatment outcome')  SET @TreatmentOutcome36Months = 1
	IF (@Bucket = 'Date of death')  SET @DateOfDeath = 1
	IF (@Bucket = 'date of birth')  SET @DateOfBirth = 1
	IF (@Bucket = 'UK born')  SET @UKBorn = 1
	IF (@Bucket = 'Site of Disease')  SET @SiteOfDisease = 1
	IF (@Bucket = 'Denotify')  SET @Denotify = 1
	IF (@Bucket = 'Onset to presentation days')  SET @OnsetToPresentationDays = 1
	IF (@Bucket = 'Presentation to diagnosis days')  SET @PresentationToDiagnosisDays = 1
	IF (@Bucket = 'Diagnosis to treatment days')  SET @DiagnosisToTreatmentDays = 1
	IF (@Bucket = 'Onset to treatment days')  SET @OnsetToTreatmentDays = 1
	IF (@Bucket = 'Postcode')  SET @Postcode = 1

			 IF (@Bucket = 'Total') 
			 begin 
				SET @TreatmentEndDate = 1
				SET @TreatmentOutcome12Months = 1
				SET @TreatmentOutcome24Months = 1
				SET @TreatmentOutcome36Months = 1
				SET @DateOfDeath = 1
				SET @DateOfBirth = 1
				SET @UKBorn = 1
				SET @SiteOfDisease = 1
				SET @Denotify = 1
				SET @OnsetToPresentationDays = 1
				SET @PresentationToDiagnosisDays = 1
				SET @DiagnosisToTreatmentDays = 1
				SET @OnsetToTreatmentDays = 1
				SET @Postcode = 1

			 end
			
							
			DECLARE @ReusableNotification ReusableNotificationType

			INSERT INTO @ReusableNotification
				SELECT distinct n.*
				FROM dbo.ufnAuthorizedReusableNotification(@LoginGroups) n

					INNER JOIN dbo.DataQuality d ON d.NotificationId = n.NotificationId
			WHERE n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo 
				AND (((@ServiceName IS NULL OR @Region IS NULL) OR @ServiceName <> 'All') OR n.TreatmentPhec = @Region)
				AND ((@ServiceName IS NULL OR @ServiceName = 'All') OR n.[Service] = @ServiceName)

				--and @TreatmentEndDate IS NULL OR d.TreatmentEndDate = @TreatmentEndDate
				
				AND (
					(( d.TreatmentEndDate = @TreatmentEndDate) OR (@TableTotal = 1 and (d.TreatmentEndDate = @TreatmentEndDate)))
					OR (( d.TreatmentOutcome12Months = @TreatmentOutcome12Months) OR (@TableTotal = 1 and (d.TreatmentOutcome12Months = @TreatmentOutcome12Months)))
					OR (( d.TreatmentOutcome24Months = @TreatmentOutcome24Months) OR (@TableTotal = 1 and (d.TreatmentOutcome24Months = @TreatmentOutcome24Months)))
					OR (( d.TreatmentOutcome36Months = @TreatmentOutcome36Months) OR (@TableTotal = 1 and (d.TreatmentOutcome36Months = @TreatmentOutcome36Months)))
					OR (( d.DateOfDeath = @DateOfDeath) OR (@TableTotal = 1 and (d.DateOfDeath = @DateOfDeath)))
					OR (( d.DateOfBirth = @DateOfBirth) OR (@TableTotal = 1 and (d.DateOfBirth = @DateOfBirth)))
					OR (( d.UKBorn = @UKBorn) OR (@TableTotal = 1 and (d.UKBorn = @UKBorn)))
					OR (( d.SiteOfDisease = @SiteOfDisease) OR (@TableTotal = 1 and (d.SiteOfDisease = @SiteOfDisease)))
					OR (( d.Denotify = @Denotify) OR (@TableTotal = 1 and (d.Denotify = @Denotify)))
					OR (( d.OnsetToPresentationDays = @OnsetToPresentationDays) OR (@TableTotal = 1 and (d.OnsetToPresentationDays = @OnsetToPresentationDays)))
					OR (( d.PresentationToDiagnosisDays = @PresentationToDiagnosisDays) OR (@TableTotal = 1 and (d.PresentationToDiagnosisDays = @PresentationToDiagnosisDays)))
					OR (( d.DiagnosisToTreatmentDays = @DiagnosisToTreatmentDays) OR (@TableTotal = 1 and (d.DiagnosisToTreatmentDays = @DiagnosisToTreatmentDays)))
					OR (( d.OnsetToTreatmentDays = @OnsetToTreatmentDays) OR (@TableTotal = 1 and (d.OnsetToTreatmentDays = @OnsetToTreatmentDays)))
					OR (( d.Postcode = @Postcode) OR (@TableTotal = 1 and (d.Postcode = @Postcode)))
				)



			SELECT distinct
			-- Primary key
			n.NotificationId                                       AS 'ID',
			-- Demographics
			n.EtsId                                                AS 'ETS ID',
			n.LtbrId											   AS 'LTBR ID',
			n.Service												As 'Service',
			n.CaseManager											AS 'Case manager',
			case 
				when @bucket = 'Treatment end date' or (@bucket = 'Total' and d.TreatmentEndDate = 1) then 'Missing treatment end date'
				when @bucket = '12 month treatment outcome' or (@bucket = 'Total' and d.TreatmentOutcome12Months = 1) then 'Missing 12 month treatment outcome'
				when @bucket = '24 month treatment outcome' or (@bucket = 'Total' and d.TreatmentOutcome24Months = 1) then 'Missing 24 month treatment outcome'
				when @bucket = '36 month treatment outcome' or (@bucket = 'Total' and d.TreatmentOutcome36Months = 1) then 'Missing 36 month treatment outcome'
				when @bucket = 'Date of death' or (@bucket = 'Total' and d.DateOfDeath = 1) then 'Missing date of death'
				when @bucket = 'date of birth' or (@bucket = 'Total' and d.DateOfBirth = 1) then 'Missing date of birth'
				when @bucket = 'UK born' or (@bucket = 'Total' and d.UKBorn = 1) then 'UK Born is Unknown'
				when @bucket = 'Site of Disease' or (@bucket = 'Total' and d.SiteOfDisease = 1) then 'Site of disease is Unknown'
				when @bucket = 'Denotify' or (@bucket = 'Total' and d.Denotify = 1) then 'Patient did not have TB'
				when @bucket = 'Onset to presentation days' or (@bucket = 'Total' and d.OnsetToPresentationDays = 1) then 'Onset to presentation days'
				when @bucket = 'Presentation to diagnosis days' or (@bucket = 'Total' and d.PresentationToDiagnosisDays = 1) then 'Presentation to diagnosis days'
				when @bucket = 'Diagnosis to treatment days' or (@bucket = 'Total' and d.DiagnosisToTreatmentDays = 1) then 'Diagnosis to treatment days'
				when @bucket = 'Onset to treatment days' or (@bucket = 'Total' and d.OnsetToTreatmentDays = 1) then 'Onset to treatment days'
				when @bucket = 'Postcode' or (@bucket = 'Total' and d.Postcode = 1) then 'Invalid postcode'
				end AS 'Error text',
			dbo.ufnFormatDateConsistently(n.NotificationDate)       AS 'Notification date',
			case when	(@bucket = 'Date of death' or (@bucket = 'Total' and d.DateOfDeath = 1) ) or 
						(@bucket = 'Treatment end date' or (@bucket = 'Total' and d.TreatmentEndDate = 1) ) OR
						(@bucket = 'Denotify' or (@bucket = 'Total' and d.Denotify = 1) ) OR
						(@bucket = '12 month treatment outcome' or (@bucket = 'Total' and d.TreatmentOutcome12Months = 1) ) OR
						(@bucket = '24 month treatment outcome' or (@bucket = 'Total' and d.TreatmentOutcome24Months = 1) ) OR
						(@bucket = '36 month treatment outcome' or (@bucket = 'Total' and d.TreatmentOutcome36Months = 1) ) 
						then n.TreatmentOutcome12months else '' end as 'Treatment outcome 12 months' ,
			case when	(@bucket = 'Date of death' or (@bucket = 'Total' and d.DateOfDeath = 1) ) or 
						(@bucket = 'Treatment end date' or (@bucket = 'Total' and d.TreatmentEndDate = 1) ) OR
						(@bucket = 'Denotify' or (@bucket = 'Total' and d.Denotify = 1) ) OR
						(@bucket = '12 month treatment outcome' or (@bucket = 'Total' and d.TreatmentOutcome12Months = 1) ) OR
						(@bucket = '24 month treatment outcome' or (@bucket = 'Total' and d.TreatmentOutcome24Months = 1) ) OR
						(@bucket = '36 month treatment outcome' or (@bucket = 'Total' and d.TreatmentOutcome36Months = 1) )
						then n.TreatmentOutcome24months else '' end as 'Treatment outcome 24 months' ,
			case when	(@bucket = 'Date of death' or (@bucket = 'Total' and d.DateOfDeath = 1) ) or 
						(@bucket = 'Treatment end date' or (@bucket = 'Total' and d.TreatmentEndDate = 1) ) OR
						(@bucket = 'Denotify' or (@bucket = 'Total' and d.Denotify = 1) ) OR
						(@bucket = '12 month treatment outcome' or (@bucket = 'Total' and d.TreatmentOutcome12Months = 1) ) OR
						(@bucket = '24 month treatment outcome' or (@bucket = 'Total' and d.TreatmentOutcome24Months = 1) ) OR
						(@bucket = '36 month treatment outcome' or (@bucket = 'Total' and d.TreatmentOutcome36Months = 1) )
						then n.TreatmentOutcome36months else '' end as 'Treatment outcome 36 months' ,
			case when	(@bucket = 'Date of death' or (@bucket = 'Total' and d.DateOfDeath = 1) ) or 
						(@bucket = 'Denotify' or (@bucket = 'Total' and d.Denotify = 1) ) OR
						(@bucket = '12 month treatment outcome' or (@bucket = 'Total' and d.TreatmentOutcome12Months = 1) ) OR
						(@bucket = '24 month treatment outcome' or (@bucket = 'Total' and d.TreatmentOutcome24Months = 1) ) OR
						(@bucket = '36 month treatment outcome' or (@bucket = 'Total' and d.TreatmentOutcome36Months = 1) )
						then n.LastRecordedTreatmentOutcome end AS 'Last recorded treatment outcome',
			case when	(@bucket = 'Date of death' or (@bucket = 'Total' and d.DateOfDeath = 1) )
						then dbo.ufnFormatDateConsistently(n.DateOfDeath)  end as 'Date of death',
			case when	(@bucket = 'date of birth' or (@bucket = 'Total' and d.DateOfBirth = 1) )
						then dbo.ufnFormatDateConsistently(n.DateOfBirth)  end AS  'Date of Birth',
			case when	(@bucket = 'UK born' or (@bucket = 'Total' and d.UKBorn = 1) )
						then n.UkBorn end as 'UK born', 
			case when	(@bucket = 'Site of Disease' or (@bucket = 'Total' and d.SiteOfDisease = 1) )
						then n.SiteOfDisease end as 'Site of disease',
			case when	(@bucket = 'Onset to presentation days' or (@bucket = 'Total' and d.OnsetToPresentationDays = 1) ) OR
						(@bucket = 'Presentation to diagnosis days' or (@bucket = 'Total' and d.PresentationToDiagnosisDays = 1) ) OR
						(@bucket = 'Diagnosis to treatment days' or (@bucket = 'Total' and d.DiagnosisToTreatmentDays = 1) ) OR
						(@bucket = 'Onset to treatment days' or (@bucket = 'Total' and d.OnsetToTreatmentDays = 1) )
						then dbo.ufnFormatDateConsistently(n.SymptomOnsetDate) end as 'Symptom onset date',
			case when	(@bucket = 'Onset to presentation days' or (@bucket = 'Total' and d.OnsetToPresentationDays = 1) ) OR
						(@bucket = 'Presentation to diagnosis days' or (@bucket = 'Total' and d.PresentationToDiagnosisDays = 1) ) OR
						(@bucket = 'Diagnosis to treatment days' or (@bucket = 'Total' and d.DiagnosisToTreatmentDays = 1) ) OR
						(@bucket = 'Onset to treatment days' or (@bucket = 'Total' and d.OnsetToTreatmentDays = 1) ) then 
						dbo.ufnFormatDateConsistently(n.PresentedDate) end as 'Presentation date' ,
			case when	(@bucket = 'Onset to presentation days' or (@bucket = 'Total' and d.OnsetToPresentationDays = 1) ) OR
						(@bucket = 'Presentation to diagnosis days' or (@bucket = 'Total' and d.PresentationToDiagnosisDays = 1) ) OR
						(@bucket = 'Diagnosis to treatment days' or (@bucket = 'Total' and d.DiagnosisToTreatmentDays = 1) ) OR
						(@bucket = 'Onset to treatment days' or (@bucket = 'Total' and d.OnsetToTreatmentDays = 1) ) then 
						dbo.ufnFormatDateConsistently(n.DiagnosisDate) end as 'Diagnosis date' ,
			case when	(@bucket = 'Onset to presentation days' or (@bucket = 'Total' and d.OnsetToPresentationDays = 1) ) OR
						(@bucket = 'Presentation to diagnosis days' or (@bucket = 'Total' and d.PresentationToDiagnosisDays = 1) ) OR
						(@bucket = 'Diagnosis to treatment days' or (@bucket = 'Total' and d.DiagnosisToTreatmentDays = 1) ) OR
						(@bucket = 'Onset to treatment days' or (@bucket = 'Total' and d.OnsetToTreatmentDays = 1) ) then 
						dbo.ufnFormatDateConsistently(n.StartOfTreatmentDate) end as 'Start of treatment date' ,
			case when	(@bucket = 'Postcode' or (@bucket = 'Total' and d.Postcode = 1) )
						 then  n.Postcode end As 'Postcode'
			
			FROM @ReusableNotification n
			inner join DataQuality d on d.NotificationId = n.NotificationId
			ORDER BY [Notification date] DESC,id 
			--order by [Error text]

			-- Write data to audit log
			
			EXEC dbo.uspAddToAudit 'Data Quality', @LoginGroups, @ReusableNotification
		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
