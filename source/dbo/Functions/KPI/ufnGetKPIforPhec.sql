CREATE FUNCTION [dbo].[ufnGetKPIforPhec]
(
	@Phec VARCHAR(50)
)
RETURNS TABLE
AS
RETURN 

	SELECT 
		[%Positive] AS 'PercentPositive',
		[%Resistant] AS 'PercentResistant',
		[%HIVOffered] AS 'PercentHIVOffered',
		[%TreatmentDelay] AS 'PercentTreatmentDelay',
		--TODO: replace with value once definition of missing treatment outcome understood for NTBS outcomes
		23.6 AS 'PercentMissingOutcome'
	
	FROM [dbo].[vwPhecKPI]
	WHERE Phec_Code = @Phec

