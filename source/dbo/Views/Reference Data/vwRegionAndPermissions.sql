/*

This view traverses the ETS permission hierarchy, showing all permissions from Tier 2 downwards and which 
region they are a part of

*/


CREATE VIEW [dbo].[vwRegionAndPermissions]
	AS 
	WITH RegionsAndPermissions AS
(
	SELECT p.PHEC_Code, p.PHEC_Name, Q1.Id
	FROM 
	[$(NTBS_R1_Geography_Staging)].[dbo].[PHEC] p
		INNER JOIN  
		(
			SELECT * 
			FROM [$(migration)].[dbo].[EtsLocationHierarchy]
			WHERE Tier = 2
		) 
		--very ugly join on name of region being in name of permission, limited to only first 8 characters
		--because the region is called Yorkshire and Humber but the permission is called Yorkshire and the Humber
		AS Q1 ON CHARINDEX(LEFT(p.PHEC_Name, 8), Q1.[NAME]) > 0
),

PermissionHierarchy AS
(	--build up the hierarchy so that every row has a field which holds the permission ID of the region
		SELECT *, Id AS RegionId 
		FROM [$(migration)].[dbo].[EtsLocationHierarchy]
		WHERE Tier = 2

		UNION

		SELECT *, ParentId AS RegionId 
		FROM [$(migration)].[dbo].[EtsLocationHierarchy]
		WHERE Tier = 3
		
		UNION
		
		SELECT servicepermission.*, hpu.ParentId AS RegionId
		FROM [$(migration)].[dbo].[EtsLocationHierarchy] as servicepermission
			INNER JOIN [$(migration)].[dbo].[EtsLocationHierarchy] AS hpu ON servicepermission.ParentId = hpu.Id
		WHERE servicepermission.Tier = 4

)

SELECT rp.PHEC_Code, rp.PHEC_Name, ph.Id, ph.[NAME] FROM
RegionsAndPermissions rp
	INNER JOIN PermissionHierarchy ph ON ph.RegionId = rp.Id
