CREATE PROCEDURE [dbo].[uspGetNotificationsInClusterWithMask]
(
	@ClusterId VARCHAR(200)
)
AS
SELECT 
	notifications.NotificationId,
	notifications.EtsId,
	notifications.LtbrId,
	FORMAT(notifications.NotificationDate, 'dd MMM yyyy') AS NotificationDate,
	notifications.Hospital,
	notifications.[Service],
	CASE WHEN notifications.CanView = 1 THEN notifications.Forename ELSE 'Withheld' END AS Forename,
	CASE WHEN notifications.CanView = 1 THEN notifications.Surname ELSE 'Withheld' END AS Surname,
	CASE WHEN notifications.CanView = 1 THEN notifications.NhsNumber ELSE 'Withheld' END AS NhsNumber,
	CASE WHEN notifications.CanView = 1 THEN FORMAT(notifications.DateOfBirth, 'dd MMM yyyy') ELSE 'Withheld' END AS DateOfBirth,
	notifications.Age,
	notifications.Sex,
	notifications.EthnicGroup,
	notifications.BirthCountry,
	notifications.UkEntryYear,
	CASE WHEN notifications.CanView = 1 THEN notifications.Postcode ELSE NULL END AS Postcode,
	notifications.NoFixedAbode,
	notifications.LocalAuthorityCode,
	notifications.LocalAuthority,
	notifications.ResidencePhec,
	notifications.TreatmentPhec,
	FORMAT(notifications.SymptomOnsetDate, 'dd MMM yyyy') AS SymptomOnsetDate,
	FORMAT(notifications.PresentedDate, 'dd MMM yyyy') AS NotificationDate,
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
FROM (
	SELECT 
		n.*,
		dbo.[ufnCanUserViewRecord](n.TreatmentPhec, n.ResidencePhec, n.Service) AS CanView
	FROM dbo.ReusableNotification n WITH (NOLOCK)
	LEFT JOIN NotificationClusterMatch cluster ON cluster.NotificationId = n.NotificationId
	WHERE ClusterId = @ClusterId
) notifications