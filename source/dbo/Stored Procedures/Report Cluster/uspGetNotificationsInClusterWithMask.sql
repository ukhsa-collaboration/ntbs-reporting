CREATE PROCEDURE [dbo].[uspGetNotificationsInClusterWithMask]
(
	@ClusterId VARCHAR(200)
)
AS
BEGIN
	BEGIN TRY
		DECLARE @LoginGroups VARCHAR(500)
		EXEC uspGetAuthenticatedLoginGroupsAndType @LoginGroups OUTPUT;

		IF (@LoginGroups != '###')
			BEGIN
				DECLARE @ReusableNotification ReusableNotificationType

				--get a list of Ids and masked values into @ReusableNotification
				--so that this can then be audited

				INSERT INTO @ReusableNotification(NotificationId, EtsId, Forename, Surname, NhsNumber, DateOfBirth, Postcode)
					SELECT
						notifications.NotificationId,
						notifications.EtsId,
						notifications.Forename,
						notifications.Surname,
						notifications.NhsNumber,
						notifications.DateOfBirth,
						notifications.Postcode
					FROM dbo.ufnAuthorizedReusableNotification(@LoginGroups) notifications
						INNER JOIN NotificationClusterMatch cluster ON cluster.NotificationId = notifications.NotificationId
					WHERE ClusterId = @ClusterId
				
				INSERT INTO @ReusableNotification(NotificationId, EtsId, Forename, Surname, NhsNumber, DateOfBirth, Postcode)
					SELECT
						rn.NotificationId,
						rn.EtsId,
						'Withheld' AS Forename,
						'Withheld' AS Surname,
						'Withheld' AS NhsNumber,
						 NULL AS DateOfBirth,
						'Withheld' AS Postcode
					FROM
						[dbo].[ReusableNotification] rn 
						INNER JOIN NotificationClusterMatch cluster ON cluster.NotificationId = rn.NotificationId AND cluster.ClusterId = @ClusterId
						AND rn.NotificationId NOT IN (SELECT NotificationId FROM @ReusableNotification)

				--now send data back to the client
				SELECT 
					notifications.NotificationId,
					notifications.EtsId,
					rn.LtbrId,
					FORMAT(rn.NotificationDate, 'dd MMM yyyy') AS NotificationDate,
					rn.Hospital,
					rn.[Service],
					notifications.Forename,
					notifications.Surname,
					notifications.NhsNumber,
					CASE 
						WHEN notifications.DateOfBirth IS NULL THEN 'Withheld' 
						ELSE FORMAT(notifications.DateOfBirth, 'dd MMM yyyy') 
					END AS DateOfBirth,
					notifications.Postcode,
					rn.Age,
					rn.Sex,
					rn.EthnicGroup,
					rn.BirthCountry,
					rn.UkEntryYear,
					rn.NoFixedAbode,
					rn.LocalAuthorityCode,
					rn.LocalAuthority,
					rn.ResidencePhec,
					rn.TreatmentPhec,
					FORMAT(rn.SymptomOnsetDate, 'dd MMM yyyy') AS SymptomOnsetDate,
					FORMAT(rn.PresentedDate, 'dd MMM yyyy') AS PresentedDate,
					FORMAT(rn.DiagnosisDate, 'dd MMM yyyy') AS DiagnosisDate,
					FORMAT(rn.StartOfTreatmentDate, 'dd MMM yyyy') AS StartOfTreatmentDate,
					rn.AnySocialRiskFactor,
					rn.Prison,
					rn.Homeless,
					rn.AlcoholMisuse,
					rn.DrugMisuse,
					rn.LastRecordedTreatmentOutcome,
					FORMAT(rn.EarliestSpecimenDate, 'dd MMM yyyy') AS StartOfTreatmentDate,
					rn.DrugResistanceProfile
				FROM @ReusableNotification notifications
					INNER JOIN [dbo].[ReusableNotification] rn ON rn.NotificationId = notifications.NotificationId
				ORDER BY notifications.NotificationDate DESC
			
			-- Write data to audit log
			EXEC dbo.uspAddToAudit 'Cluster Line List', @LoginGroups, @ReusableNotification
		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
END