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
		,cars.PYR AS 'Pyrazinamide'
		,cars.ETHAM AS 'Ethambutol'
		,cars.AMINO AS 'Aminoglycocide'
		,cars.QUIN AS 'Quinolone'
		,cars.MDR
		,cars.XDR
      
  FROM [dbo].[CultureAndResistanceSummary] cars
  WHERE cars.NotificationId = @NTBSId