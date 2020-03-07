CREATE VIEW [dbo].[vwSecondLineMapping]
	AS 
		--using mappings from R1
		SELECT 'AMINO' AS GroupName, 'AMINO' AS AntibioticOutputName
		UNION
		SELECT 'AMINO' AS GroupName, 'AK' AS AntibioticOutputName
		UNION
		SELECT 'AMINO' AS GroupName, 'AMI' AS AntibioticOutputName
		UNION
		SELECT 'AMINO' AS GroupName, 'KAN' AS AntibioticOutputName
		UNION
		SELECT 'AMINO' AS GroupName, 'CAP' AS AntibioticOutputName
		UNION
		SELECT 'AMINO' AS GroupName, 'STR' AS AntibioticOutputName
		UNION
		SELECT 'QUIN' AS GroupName, 'QUIN' AS AntibioticOutputName
		UNION
		SELECT 'QUIN' AS GroupName, 'OFX' AS AntibioticOutputName
		UNION
		SELECT 'QUIN' AS GroupName, 'MOXI' AS AntibioticOutputName
		UNION
		SELECT 'QUIN' AS GroupName, 'CIP' AS AntibioticOutputName
		UNION
		SELECT 'QUIN' As 'GroupName', 'OFL' AS AntibioticOutputName

