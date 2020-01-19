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
		[%Positive] AS 'PercentPositive',
		[%Resistant] AS 'PercentResistant',
		[%HIVOffered] AS 'PercentHIVOffered',
		[%TreatmentDelay] AS 'PercentTreatmentDelay',
		--TODO: replace with value once definition of missing treatment outcome understood for NTBS outcomes
		23.6 AS 'PercentMissingOutcome'
	
	FROM [dbo].[vwPhecKPI]
	WHERE PHEC_Code IN (SELECT TRIM(VALUE) FROM STRING_SPLIT(@Phec, ','))

