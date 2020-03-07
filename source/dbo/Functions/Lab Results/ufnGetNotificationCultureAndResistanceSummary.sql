CREATE FUNCTION [dbo].[ufnGetNotificationCultureAndResistanceSummary]
(
	@NTBSId int
)

RETURNS TABLE
AS

RETURN
SELECT	cars.NotificationId
		,cars.CulturePositive
		,cars.Species
		,cars.EarliestSpecimenDate
		,cars.DrugResistanceProfile
		,cars.INH AS 'Isoniazid'
		,cars.RIF AS 'Rifampicin'
		,cars.PZA AS 'Pyrazinamide'
		,cars.EMB AS 'Ethambutol'
		,cars.AMINO AS 'Aminoglycoside'
		,cars.QUIN AS 'Quinolone'
		,cars.MDR
		,cars.XDR
      
  FROM [dbo].ReusableNotification cars
  WHERE cars.NotificationId = CONVERT(nvarchar, @NTBSId)