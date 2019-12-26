CREATE VIEW [dbo].[vwManualLabResult]
	AS 
	
	/*this fetches the highest ranked (i.e. Positive outranks Negative) result for each type of manual lab result
	for each notification in the reusable notification table)*/

	

	--OUTER QUERY converts the minrank back to a result
	SELECT Q1.LegacyID, 
		Q1.[Name],
		(CASE Q1.ResultRank
			WHEN 1 THEN 'Positive'
			WHEN 2 THEN 'Negative'
			WHEN 3 THEN 'Not known'
			WHEN 4 THEN 'Awaiting'
			ELSE NULL
		END) AS 'Result' FROM
		--INNER QUERY SELECTS THE HIGHEST RANKED RESULT FOR EACH COMBINATION OF NOTIFICATION ID AND TEST
		(SELECT DISTINCT n.LegacyId
			  ,lc.[Name]
				,MIN((CASE lr.Result
					WHEN 0 THEN 2
					WHEN 1 THEN 1
					WHEN 2 THEN 3
					WHEN 3 THEN 4
					ELSE NULL
				END)) AS 'ResultRank'
				
		  FROM [$(ETS)].[dbo].[LaboratoryResult] lr
			INNER JOIN [$(ETS)].[dbo].[Notification] n on n.Id = lr.NotificationId
			INNER JOIN [$(ETS)].[dbo].[LaboratoryCategory] lc on lc.Id = lr.LaboratoryCategoryId
			INNER JOIN [$(ETS)].[dbo].[SpecimenType] st on st.Id = lr.SpecimenTypeId
		WHERE OpieId is NULL
		GROUP BY n.LegacyId, lc.[Name]) AS Q1
			INNER JOIN [dbo].ReusableNotification rn ON rn.EtsId = Q1.LegacyId
