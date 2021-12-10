CREATE VIEW [dbo].[vwDrugResistanceProfiles]
	AS 
		SELECT * FROM 
			(VALUES 
				('Sensitive to first line'),
				('INH+RIF sensitive'),
				('INH resistant'),
				('RR/MDR/XDR'),
				('No result')
			) AS DRPs(DrugResistanceProfile)