CREATE FUNCTION [dbo].[ufnGetKPIforPhec]
(
	--comma-separated list to be split using select value from STRING_SPLIT
	@Phec VARCHAR(200)		=	NULL
)
RETURNS TABLE
AS
RETURN 

	SELECT 
		PHEC_Code AS Code,
		PHEC_Name AS 'Name',
		[%Positive] AS 'PercentPositive',
		[%Resistant] AS 'PercentResistant',
		[%HIVOffered] AS 'PercentHIVOffered',
		[%TreatmentDelay] AS 'PercentTreatmentDelay'
	
	FROM [dbo].[vwPhecKPI]
	WHERE PHEC_Code IN (SELECT TRIM(VALUE) FROM STRING_SPLIT(@Phec, ','))

