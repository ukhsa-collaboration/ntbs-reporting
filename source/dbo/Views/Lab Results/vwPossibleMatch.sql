CREATE VIEW [dbo].[vwPossibleMatch]
	AS 
	SELECT 
		nsm.ReferenceLaboratoryNumber
		,ls.SpecimenDate
		,ls.SpecimenTypeCode
		,ls.LaboratoryName
		,ls.ReferenceLaboratory
		,ls.Species

		,ls.PatientNhsNumber AS 'LabNhsNumber'
		,ls.PatientBirthDate AS 'LabBirthDate'
		,ls.PatientName AS 'LabName'
		,ls.PatientSex AS 'LabSex'
		,ls.PatientAddress AS 'LabAddress'
		,ls.PatientPostcode AS 'LabPostcode'
		,tbs.PHECCode
		,tbs.Code
		,tbs.[Name] AS 'TbServiceName'
		,nsm.NotificationID
		,n.NotificationDate
		,
		(CASE p.NhsNumberNotKnown 
			WHEN 1 THEN 'Not known'
			ELSE p.NhsNumber
		END) AS 'NtbsNhsNumber'
		,CONCAT(UPPER(p.FamilyName), ', ', p.GivenName) AS 'NtbsName'
		,s.Label AS 'NtbsSex'
		,p.Dob AS 'NtbsBirthDate'
		,p.[Address] AS 'NtbsAddress'
		,p.Postcode AS 'NtbsPostcode'
		,nsm.ConfidenceLevel

	FROM [$(NTBS_Specimen_Matching)].[dbo].NotificationSpecimenMatch nsm
		INNER JOIN [dbo].[LabSpecimen] ls ON ls.ReferenceLaboratoryNumber = nsm.ReferenceLaboratoryNumber
		INNER JOIN [$(NTBS)].[dbo].[Notification] n ON n.NotificationId = nsm.NotificationID
		INNER JOIN [$(NTBS)].[dbo].[HospitalDetails] e ON e.NotificationId = nsm.NotificationID
		INNER JOIN [$(NTBS)].[dbo].[Patients] p ON p.NotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[TbService] tbs ON e.TBServiceCode = tbs.Code
		LEFT OUTER JOIN [$(NTBS)].[dbo].[Sex] s ON s.SexId = p.SexId
	WHERE nsm.MatchType = 'Possible' 
