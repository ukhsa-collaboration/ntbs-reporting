CREATE VIEW [dbo].[vwConfirmedMatch]
	AS 
		SELECT nms.NotificationID
              ,ls.[LabSpecimenId]
              ,ls.[ReferenceLaboratoryNumber]
              ,ls.[SpecimenDate]
              ,ls.[SpecimenTypeCode]
              ,ls.[LaboratoryName]
              ,ls.[ReferenceLaboratory]
              ,ls.[Species]
              ,ls.[INH]
              ,ls.[RIF]
              ,ls.[PZA]
              ,ls.[EMB]
              ,ls.[MDR]
              ,ls.[AMINO]
              ,ls.[QUIN]
              ,ls.[XDR]
              ,ls.[PatientNhsNumber]
              ,ls.[PatientBirthDate]
              ,ls.[PatientName]
              ,ls.[PatientGivenName]
              ,ls.[PatientFamilyName]
              ,ls.[PatientSex]
              ,ls.[PatientAddress]
            ,ls.[PatientPostcode] 
        FROM [$(NTBS_Specimen_Matching)].[dbo].NotificationSpecimenMatch nms
		    INNER JOIN dbo.LabSpecimen ls ON ls.ReferenceLaboratoryNumber = nms.ReferenceLaboratoryNumber
		WHERE nms.MatchType = 'Confirmed'
