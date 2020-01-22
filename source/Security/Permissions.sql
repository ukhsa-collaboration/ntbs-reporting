/***************************************************************************************************
Desc:    This implements permissions on the DB objects in the NTBS_R1_Reporting_Staging database.
         On top of this, there is the PHEC-region-specific security model that was implemented
		 programatically through SQL code in the folders \Functions\Authorization, 
		 \Stored Procedures\Authorization and \Tables\Authorization.
         


         
**************************************************************************************************/

-- Deny by default. SQL Server should behave this way anyway, so this is just
-- for good measures (in case this is a non-default SQL Server instance)


--removed as do not have full permissions on PHE Cluster to edit permissions
/*
DENY DELETE TO PUBLIC
GO
DENY ALTER TO PUBLIC
GO

-- TODO: Can we deny users from browsing all reporting DB objects by default, and only allow the ones that are relevant for them !?
GRANT VIEW DEFINITION TO PUBLIC
GO

-- Grant only those htings required to for end-users to access Report Builder
GRANT CONNECT TO PUBLIC AS [dbo]
GO
GRANT SELECT TO PUBLIC AS [dbo]
GO
GRANT EXEC TO PUBLIC AS [dbo]
GO

-- Deny regional users notifications across all regions
DENY SELECT ON ReusableNotification TO PUBLIC AS [dbo]
GO
*/