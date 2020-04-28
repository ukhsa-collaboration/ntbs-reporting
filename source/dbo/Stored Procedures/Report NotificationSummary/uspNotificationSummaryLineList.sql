/***************************************************************************************************
Desc:    This serves the "Notification Summary" notification aggregate counts for the residence
         portion of the report's entry web page.


         
**************************************************************************************************/

Create PROCEDURE [dbo].[uspNotificationSummaryLineList]
(
		@NotificationYearFrom	INTEGER			=	NULL,
		@NotificationMonthFrom	INTEGER			=	NULL,
		@NotificationYearTo		INTEGER			=	NULL,
		@NotificationMonthTo	INTEGER			=	NULL,
		@NotificationPeriod		VARCHAR(8)		=	NULL,
		@LocalAuthority			VARCHAR(50)		=	NULL,
		@Service				VARCHAR(5000)	=	NULL,
		@GroupBy				VARCHAR(50)		=	NULL,
		@Region					VARCHAR(50)		=	NULL
	)
AS
	SET NOCOUNT ON

	-- Debugging
	-- EXEC master..xp_logevent 60000, @Region
	
	BEGIN TRY
		DECLARE	@LoginGroups VARCHAR(500)
		EXEC dbo.uspGetAuthenticatedLoginGroups @LoginGroups OUTPUT

		IF (@LoginGroups != '###')
		BEGIN
			DECLARE @NotificationYearTypeFrom	VARCHAR(16) = NULL
			DECLARE @NotificationDateFrom		DATE = NULL
			DECLARE @NotificationYearTypeTo		VARCHAR(16) = NULL
			DECLARE @NotificationDateTo			DATE = NULL
			DECLARE @NotificationMonth			VARCHAR(8) = NULL
			DECLARE @NotificationYear			VARCHAR(4) = NULL
			declare @NotificationPeriodMonth	varchar(2) = null
			Declare @NotificationPeriodYear		VARCHAR(4) = null

			IF (@NotificationYearFrom IS NOT NULL AND @NotificationMonthFrom IS NOT NULL AND @NotificationYearTo IS NOT NULL AND @NotificationMonthTo IS NOT NULL 
				and @NotificationPeriod IS null)
			BEGIN
				SET @NotificationYearTypeFrom	= YEAR(DATEADD(YEAR, @NotificationYearFrom, GETDATE()))
				SET @NotificationDateFrom		= CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthFrom) + '/01/' + @NotificationYearTypeFrom)
				SET @NotificationYearTypeTo		= YEAR(DATEADD(YEAR, @NotificationYearTo, GETDATE()))
				SET @NotificationDateTo			= CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthTo) + '/01/' + @NotificationYearTypeTo)
				SET @NotificationDateTo			= EOMONTH(@NotificationDateTo)
			END
			ELSE IF (@NotificationPeriod IS NOT NULL)
			BEGIN
				IF (@GroupBy = 'MONTH')
				Begin
					set @NotificationPeriodMonth = right(@NotificationPeriod,2)
					set @NotificationPeriodYear = left(@notificationPeriod,4)
					 set @NotificationDateFrom = CONVERT(DATE, @NotificationPeriodMonth + '/01/' + @NotificationPeriodYear)
					 set @NotificationDateTo =  EOMONTH(@NotificationDateFrom)
				End
					--SET @NotificationMonth = @NotificationPeriodMonth
				ELSE IF (@GroupBy = 'YEAR')
					Begin
						set @NotificationPeriodYear = @NotificationPeriod
						set @NotificationDateFrom = CONVERT(DATE,'01'  + '/01/' + @NotificationPeriodYear)
						set @NotificationDateTo =   CONVERT(DATE, '12' + '/31/' + @NotificationPeriodYear)  
					End
				ELSE 
					RAISERROR ('The @GroupBy argument passed is invalid', 16, 1) WITH NOWAIT
			END
			ELSE 
				RAISERROR ('Either the @NotificationYear/Month/From/To arguments or the @NotificationPeriod argument passed are invalid', 16, 1) WITH NOWAIT

			DECLARE @ReusableNotification ReusableNotificationType

			INSERT INTO @ReusableNotification
				SELECT n.*
				FROM dbo.ufnAuthorizedReusableNotification(@LoginGroups) n  -- This filters the records by regional PHEC permissions!
				WHERE ((@NotificationDateFrom IS NULL AND @NotificationDateTo IS NULL) OR (n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo))
					AND (@NotificationMonth IS NULL OR FORMAT(n.NotificationDate, 'MMM yyyy') = @NotificationMonth)
					AND (@NotificationYear IS NULL OR FORMAT(n.NotificationDate, 'yyyy') = @NotificationYear)
					AND (((@Service IS NULL OR @Region IS NULL) OR @Service <> 'All') OR n.TreatmentPhec = @Region)
					AND (((@LocalAuthority IS NULL OR @Region IS NULL) OR @LocalAuthority <> 'All') OR n.ResidencePhec = @Region)
					AND ((@Service IS NULL OR @Service = 'All') OR 
						n.[Service] in (select value from STRING_SPLIT(@Service, ',')) or
					--n.[Service] = @Service or 
								(@Service = 'Blank' and [Service] is null and n.ResidencePhec = @region and n.TreatmentPhec is null))
					AND ((@LocalAuthority IS NULL OR @LocalAuthority = 'All') OR n.LocalAuthority = @LocalAuthority)


			SELECT
				-- Primary key
				--n.NotificationId                                       AS 'ID',

				-- Demographics
				n.EtsId                                                AS 'ETS ID',
				n.LtbrId                                               AS 'LTBR ID',
				dbo.ufnFormatDateConsistently(n.NotificationDate)      AS 'Notification date',
				n.CaseManager                                          AS 'Case manager',
				n.Consultant                                           AS 'Consultant',
				n.Hospital                                             AS 'Hospital',
				n.[Service]                                            AS 'Service',
				n.NhsNumber                                            AS 'NHS Number',
				n.Forename                                             AS 'Forename',
				n.Surname                                              AS 'Surname',
				dbo.ufnFormatDateConsistently(n.DateOfBirth)           AS 'Date of birth',
				n.Age                                                  AS 'Age',
				n.Sex                                                  AS 'Sex',
				n.Ukborn                                               AS 'UK born',
				n.EthnicGroup                                          AS 'Ethnic group',
				n.BirthCountry                                         AS 'Birth country',
				n.UkEntryYear                                          AS 'UK entry year',
				n.Postcode                                             AS 'Postcode',
				n.NoFixedAbode                                         AS 'No fixed abode',

				-- Geographies
				n.LocalAuthority                                       AS 'Local Authority',
				n.LocalAuthorityCode                                   AS 'Local Authority Code',
				n.ResidencePhec                                        AS 'Residence PHEC',
				n.TreatmentPhec                                        AS 'Treatment PHEC'

			FROM @ReusableNotification n
			ORDER BY n.NotificationDate DESC

			-- Write data to audit log
			EXEC dbo.uspAddToAudit 'Notification Summary', @LoginGroups, @ReusableNotification
		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
