-- ================================================

USE [NTBS_Reporting_Staging]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[ufnGetUnmatchedSpecimensByService] 
(	
	--comma-separated list to be split using select value from STRING_SPLIT(@Service, ',')
	@Service VARCHAR(1000)		=	NULL
	
)
RETURNS TABLE 
AS
RETURN 
(
	
	SELECT * FROM [dbo].TemporaryLabSpecimen
)
GO