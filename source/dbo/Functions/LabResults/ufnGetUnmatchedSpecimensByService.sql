-- ================================================

USE [NTBS_Reporting_Staging]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER FUNCTION [dbo].[ufnGetUnmatchedSpecimensByService] 
(	
	--should be an array
	@Service VARCHAR(50)		=	NULL
	
)
RETURNS TABLE 
AS
RETURN 
(
	
	SELECT * FROM [dbo].TemporaryLabSpecimen
)
GO