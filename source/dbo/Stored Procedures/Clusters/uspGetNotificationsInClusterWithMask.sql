CREATE PROCEDURE [dbo].[uspGetNotificationsInClusterWithMask]
(
	@ClusterId VARCHAR(200)
)
AS
BEGIN
	DECLARE @LoginGroups VARCHAR(500)
	EXEC uspGetAuthenticatedLoginGroups @LoginGroups OUTPUT;

	WITH unmaskedNotifications AS (
		SELECT
			notifications.NotificationId,
			-- Make sure none of these are NULL to avoid them being wrongly marked as "withheld" below.
			COALESCE(Forename, '') AS Forename,
			COALESCE(Surname, '') AS Surname,
			COALESCE(NhsNumber, '') AS NhsNumber,
			COALESCE(DateOfBirth, '') AS DateOfBirth,
			COALESCE(Postcode, '') AS Postcode
		FROM dbo.ufnAuthorizedReusableNotification(@LoginGroups) notifications
		LEFT JOIN NotificationClusterMatch cluster ON cluster.NotificationId = notifications.NotificationId
		WHERE ClusterId = @ClusterId
	)

	SELECT 
		notifications.NotificationId,
		notifications.EtsId,
		notifications.LtbrId,
		FORMAT(notifications.NotificationDate, 'dd MMM yyyy') AS NotificationDate,
		notifications.Hospital,
		notifications.[Service],
		COALESCE(un.Forename, 'Withheld') AS Forename,
		COALESCE(un.Surname, 'Withheld') AS Surname,
		COALESCE(un.NhsNumber, 'Withheld') AS NhsNumber,
		COALESCE(FORMAT(un.DateOfBirth, 'dd MMM yyyy'), 'Withheld') AS DateOfBirth,
		COALESCE(un.Postcode, 'Withheld') AS Postcode,
		notifications.Age,
		notifications.Sex,
		notifications.EthnicGroup,
		notifications.BirthCountry,
		notifications.UkEntryYear,
		notifications.NoFixedAbode,
		notifications.LocalAuthorityCode,
		notifications.LocalAuthority,
		notifications.ResidencePhec,
		notifications.TreatmentPhec,
		FORMAT(notifications.SymptomOnsetDate, 'dd MMM yyyy') AS SymptomOnsetDate,
		FORMAT(notifications.PresentedDate, 'dd MMM yyyy') AS PresentedDate,
		FORMAT(notifications.DiagnosisDate, 'dd MMM yyyy') AS DiagnosisDate,
		FORMAT(notifications.StartOfTreatmentDate, 'dd MMM yyyy') AS StartOfTreatmentDate,
		notifications.AnySocialRiskFactor,
		notifications.Prison,
		notifications.Homeless,
		notifications.AlcoholMisuse,
		notifications.DrugMisuse,
		notifications.LastRecordedTreatmentOutcome,
		FORMAT(notifications.EarliestSpecimenDate, 'dd MMM yyyy') AS EarliestSpecimenDate,
		notifications.DrugResistanceProfile
	FROM ReusableNotification notifications
	LEFT JOIN NotificationClusterMatch cluster ON cluster.NotificationId = notifications.NotificationId
	LEFT JOIN unmaskedNotifications un ON un.NotificationId = notifications.NotificationId
	WHERE ClusterId = @ClusterId

END