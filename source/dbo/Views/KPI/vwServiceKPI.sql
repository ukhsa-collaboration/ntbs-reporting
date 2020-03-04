CREATE VIEW [dbo].[vwServiceKPI]
	
AS
	SELECT tbs.TB_Service_Code, tbs.TB_Service_Name,
		COALESCE (Q1.NumberofNotifications, 0) As NumberOfNotifications,
		COALESCE (Q1.HIVDenominator, 0) As HIVDenominator,
		COALESCE (CAST((Q1.CPCount * 100.0) / NULLIF(Q1.NumberOfNotifications,0) AS DECIMAL(10, 1)), 0.0) AS '%Positive', 
		COALESCE (CAST((Q1.ResistantCount * 100.0) / NULLIF(Q1.NumberOfNotifications,0) AS DECIMAL(10, 1)), 0.0) As '%Resistant',
		--this should be on Q1.HIVDenominator but it causes a divide by zero error?  Maybe use a NULLIF?
		COALESCE (CAST((Q1.HIVOffered * 100.0) / NULLIF(Q1.HIVDenominator,0) AS DECIMAL(10, 1)), 0.0) As '%HIVOffered',
		COALESCE (CAST((Q1.TreatmentDelays * 100.0) / NULLIF(Q1.NumberOfPulmonaryNotifications, 0) AS DECIMAL(10, 1)), 0.0) As '%TreatmentDelay'
		
		FROM [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service] tbs
		LEFT OUTER JOIN 
			(SELECT rn.TBServiceCode, 
					SUM(CASE WHEN CulturePositive='Yes' THEN 1 ELSE 0 END) AS CPCount,
					SUM(CASE WHEN CulturePositive='No' THEN 1 ELSE 0 END) AS CNCount,
					SUM(CASE WHEN DrugResistanceProfile IN ('RR/MDR/XDR', 'INH Resistant') THEN 1 ELSE 0 END) AS ResistantCount, 
					SUM(CASE WHEN HivTestOffered = 'Offered' THEN 1 ELSE 0 END) AS HIVOffered,
					SUM(CASE WHEN HivTestOffered IN ('Offered', 'Not offered') THEN 1 ELSE 0 END) AS HIVDenominator,
					SUM(CASE WHEN OnsetToTreatmentDays > 120 and SiteOfDisease = 'Pulmonary' THEN 1 ELSE 0 END) AS TreatmentDelays,
					SUM(CASE WHEN SiteOfDisease = 'Pulmonary' THEN 1 ELSE 0 END) AS NumberOfPulmonaryNotifications,
					COUNT(rn.EtsId) as 'NumberOfNotifications'
				from  [dbo].ReusableNotification rn 
				WHERE rn.NotificationDate between getDate()-395 and getDate()-30
				GROUP BY rn.TBServiceCode) AS Q1
		ON Q1.TBServiceCode = tbs.TB_Service_Code