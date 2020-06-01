CREATE PROCEDURE [dbo].[uspGetNotificationsInClusterWithMask]
(
	@ClusterId VARCHAR(200)
)
AS
SELECT 
	notifications.NotificationId,
	notifications.EtsId,
	notifications.LtbrId,
	notifications.NotificationDate,
	notifications.Hospital,
	notifications.[Service],
	CASE WHEN notifications.CanView = 1 THEN notifications.Forename ELSE NULL END AS Forename,
	CASE WHEN notifications.CanView = 1 THEN notifications.Surname ELSE NULL END AS Surname,
	CASE WHEN notifications.CanView = 1 THEN notifications.NhsNumber ELSE NULL END AS NhsNumber,
	CASE WHEN notifications.CanView = 1 THEN notifications.DateOfBirth ELSE NULL END AS DateOfBirth,
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
	notifications.SymptomOnsetDate,
	notifications.PresentedDate,
	notifications.DiagnosisDate,
	notifications.StartOfTreatmentDate,
	notifications.AnySocialRiskFactor,
	notifications.Prison,
	notifications.Homeless,
	notifications.AlcoholMisuse,
	notifications.DrugMisuse,
	notifications.LastRecordedTreatmentOutcome,
	notifications.EarliestSpecimenDate,
	notifications.DrugResistanceProfile
FROM (
	SELECT 
		n.*,
		dbo.[ufnCanUserViewRecord](n.TreatmentPhec, n.ResidencePhec, n.Service) AS CanView
	FROM dbo.ReusableNotification n WITH (NOLOCK)
	LEFT JOIN NotificationClusterMatch cluster ON cluster.NotificationId = n.NotificationId
	WHERE ClusterId = @ClusterId
) notifications