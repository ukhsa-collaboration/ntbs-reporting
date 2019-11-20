/***************************************************************************************************
Desc:    This returns all of the Local Authorities of a region


         
**************************************************************************************************/

CREATE FUNCTION dbo.ufnGetLAsByRegion (
	@Region				VARCHAR(50)		=	NULL
)
	RETURNS TABLE
AS
RETURN
	SELECT 
		l.LA_Name AS LocalAuthority
	FROM [$(NTBS_R1_Geography_Staging)].dbo.Local_Authority l WITH (NOLOCK)
		INNER JOIN [$(NTBS_R1_Geography_Staging)].dbo.LA_to_PHEC lp ON lp.LA_Code = l.LA_Code
		INNER JOIN [$(NTBS_R1_Geography_Staging)].dbo.PHEC p ON p.PHEC_Code = lp.PHEC_Code
	WHERE p.PHEC_Name = @Region
