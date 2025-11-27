CREATE FUNCTION [dbo].[ufnGetKPIforService]
(
	--comma-separated list to be split using select value from STRING_SPLIT(@Service, ',')
	@Phec VARCHAR(5000) = NULL,
    @Service VARCHAR(5000) = NULL
)
RETURNS TABLE
AS
RETURN 

	SELECT 
		TB_Service_Code AS Code,
		TB_Service_Name AS 'Name',
		PHEC_Code AS 'PhecCode',
        PHEC_Name AS 'PhecName',
		[%Positive] AS 'PercentPositive',
		[%Resistant] AS 'PercentResistant',
		[%HIVOffered] AS 'PercentHIVOffered',
		[%TreatmentDelay] AS 'PercentTreatmentDelay'
	
	FROM [dbo].[vwServiceKPI]
	WHERE
        (@Phec IS NULL OR PHEC_Code IN (
            SELECT TRIM(value) FROM STRING_SPLIT(@Phec, ',')
        ))
        AND
        (@Service IS NULL OR TB_Service_Code IN (
            SELECT TRIM(value) FROM STRING_SPLIT(@Service, ',')
        ));

