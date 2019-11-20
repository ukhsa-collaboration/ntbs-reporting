/***************************************************************************************************
Desc:    This returns the pre-calculated footer text that gets displayed underneath every SSRS report
         (calculated by uspGenerateFooter).


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspFooter] AS
	SET NOCOUNT ON

	BEGIN TRY
		SELECT 
			FooterTextId,
			FooterText
		FROM dbo.FooterText
	END TRY

	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
