CREATE VIEW [dbo].[vwLocalAuthority]
	AS
	SELECT la.LA_Code, la.LA_Name, l2p.PHEC_Code 
	FROM [$(NTBS_R1_Geography_Staging)].[dbo].[Local_Authority] la
	INNER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[LA_to_PHEC] l2p ON la.LA_Code = l2p.LA_Code
GO

