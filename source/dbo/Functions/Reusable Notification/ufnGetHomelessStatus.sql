/***************************************************************************************************
Desc:    This re/calculates the value for the data points ReusableNotification.CurrentlyHomeless,
		 and a few other ReusableNotification data points for each notification record (every night when 
		 the uspGenerate schedule runs). The inline comments no 1, 2, 3 ... below have been copied 
		 across from the NTBS R1 specification in Confluence, and are to be kept in sync with that 
		 specification.


         
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnGetHomelessStatus] (
	@HomelessStatusId INT,
	@Homeless TINYINT,
	@TuberculosisHistoryId UNIQUEIDENTIFIER
)
	RETURNS NVARCHAR(255)
AS
	BEGIN
		DECLARE @ReturnValue AS NVARCHAR(255) = NULL

		IF (@Homeless = 1)
			SET @ReturnValue = (SELECT 'Yes'
								FROM [$(OtherServer)].[$(ETS)].dbo.RiskFactorHomelessStatus r
									INNER JOIN [$(OtherServer)].[$(ETS)].dbo.TuberculosisHistoryHomelessStatus th ON th.HomelessStatusId = r.Id
								WHERE th.TuberculosisHistoryId = @TuberculosisHistoryId
									AND r.LegacyId = @HomelessStatusId)

		--return NULL if no value

		RETURN @ReturnValue
	END
