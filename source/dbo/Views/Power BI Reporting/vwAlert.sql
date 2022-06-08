CREATE VIEW [dbo].[vwAlert]
	AS
	SELECT 
		a.NotificationId,
		a.AlertId,
		a.AlertStatus,
		a.AlertType,
        	COALESCE(Q1.AlertTypeDescription, 'Error') AS AlertTypeDescription,
		a.ClosingUserId,
		a.ClosureDate,
		a.CreationDate,
		a.DuplicateId,
		a.SpecimenId,
		a.TBServiceCode AS AlertTBServiceCode,
		hd.TBServiceCode

  FROM [$(NTBS)].[dbo].Alert a
		LEFT OUTER JOIN [$(NTBS)].[dbo].[HospitalDetails] hd ON hd.NotificationId = a.NotificationId
		LEFT OUTER JOIN 
		    (SELECT 'DataQualityDotVotAlert' AS AlertType, 'DOT inconsistency' AS AlertTypeDescription
		    UNION
		    SELECT 'DataQualityTreatmentOutcome12' AS AlertType,  '12 month outcome' AS AlertTypeDescription
		    UNION
		    SELECT 'DataQualityTreatmentOutcome24' AS AlertType,  '24 month outcome' AS AlertTypeDescription
		    UNION
		    SELECT 'DataQualityTreatmentOutcome36' AS AlertType,  '36 month outcome' AS AlertTypeDescription
		    UNION
		    SELECT 'DataQualityBirthCountry' AS AlertType, 'Unknown birth country' AS AlertTypeDescription
		    UNION
		    SELECT 'DataQualityDraft' AS AlertType, 'Draft' AS AlertTypeDescription
		    UNION
		    SELECT 'DataQualityCluster'  AS AlertType, 'Cluster' AS AlertTypeDescription
		    UNION
		    SELECT 'DataQualityClinicalDates'  AS AlertType, 'Clinical Dates' AS AlertTypeDescription
		    UNION
		    SELECT 'DataQualityPotentialDuplicate'  AS AlertType, 'Potential duplicate' AS AlertTypeDescription
		    UNION
		    SELECT 'EnhancedSurveillanceMDR'  AS AlertType, 'RR/MDR/XDR-TB' AS AlertTypeDescription
		    UNION
		    SELECT 'EnhancedSurveillanceMbovis'  AS AlertType, 'M. bovis' AS AlertTypeDescription
		    UNION
		    SELECT 'TransferRequest'  AS AlertType, 'Transfer request' AS AlertTypeDescription
		    UNION
		    SELECT 'TransferRejected'  AS AlertType, 'Transfer rejected' AS AlertTypeDescription
		    UNION
		    SELECT 'DataQualityChildECMLevel'  AS AlertType, 'Child ECM level' AS AlertTypeDescription
		    UNION
		    SELECT 'UnmatchedLabResult'  AS AlertType, 'Unmatched specimen' AS AlertTypeDescription) AS Q1 ON Q1.AlertType = a.AlertType
