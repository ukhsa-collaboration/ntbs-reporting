CREATE PROCEDURE [dbo].[uspMigrationDubiousSpecimenMatches]

AS
BEGIN TRY
SET NOCOUNT ON


--Create backup of table so previous set of results remain available.
TRUNCATE TABLE MigrationDubiousSpecimenMatchesBackup

INSERT INTO MigrationDubiousSpecimenMatchesBackup 
SELECT * FROM MigrationDubiousSpecimenMatches

TRUNCATE TABLE MigrationDubiousSpecimenMatches

Create Table #NotificationsInScope (EtsId int, MinEventDate Date,MaxEventDate Date, MinSpecimenDate Date, MaxSpecimenDate Date, NhsNumber VARCHAR(20))
INSERT into #NotificationsInScope 

    select EtsId
   ,(Select Min(EDate) From (Values(SymptomOnsetDate),(DiagnosisDate),(StartOfTreatmentDate),(NotificationDate)) as v (EDate)) as [MinEventDate]
   ,(Select Max(EDate) From (Values(SymptomOnsetDate),(DiagnosisDate),(StartOfTreatmentDate),(NotificationDate),(TreatmentEndDate),(DateOfDeath),(MdrTreatmentDate)) as v (EDate)) as [MaxEventDate]
   ,NULL
   ,NULL
   ,pd.NhsNumberToLookup
  from RecordRegister rr 
  inner join Record_CaseData cd on cd.NotificationId = rr.NotificationId
  inner join Record_PersonalDetails pd ON pd.NotificationId = rr.NotificationId
    where year(rr.NotificationDate) in ( SELECT NotificationYear From vwNotificationYear) and  rr.SourceSystem = 'ETS'
  and rr.NotificationId in (select distinct LegacyId 
                                from [$(NTBS_Specimen_Matching)].dbo.EtsSpecimenMatch)

--calculate the allowable date range (365 days either side of the min and max dates for a notification)

UPDATE #NotificationsInScope
    SET 
        MinSpecimenDate = DATEADD(DAY, -365, MinEventDate),
        MaxSpecimenDate = DATEADD(DAY, 365, MaxEventDate)

------------------------------------------------------------------------------------------------------------
--where one specimen has been matched to two different notifications.

select distinct e.* into #SpecimenMultipleNotificationMatchFlag from [$(NTBS_Specimen_Matching)].dbo.EtsSpecimenMatch e
INNER JOIN (

--Find multimatches
SELECT ReferenceLaboratoryNumber FROM [$(NTBS_Specimen_Matching)].dbo.EtsSpecimenMatch 
WHERE 
ReferenceLaboratoryNumber IN (
SELECT DISTINCT ReferenceLaboratoryNumber FROM #NotificationsInScope N
INNER JOIN [$(NTBS_Specimen_Matching)].dbo.EtsSpecimenMatch E ON E.LegacyId = N.EtsId)  
GROUP BY ReferenceLaboratoryNumber
having COUNT(*) >1)  AS Q1 on Q1.ReferenceLaboratoryNumber = e.ReferenceLaboratoryNumber
 order by e.ReferenceLaboratoryNumber

INSERT INTO MigrationDubiousSpecimenMatches(EtsId,ReferenceLaboratoryNumber, SpecimenMultipleNotificationMatchFlag)
SELECT DISTINCT LegacyId,ReferenceLaboratoryNumber,1 FROM #SpecimenMultipleNotificationMatchFlag
------------------------------------------------------------------------------------------------------------
/*specimen date is outside the notification date range*/

   select e.* into #SpecimenDateRangeFlag from [$(NTBS_Specimen_Matching)].dbo.EtsSpecimenMatch e 
   inner join #NotificationsInScope n on n.EtsId = e.LegacyId
   where SpecimenDate NOT BETWEEN n.MinSpecimenDate AND n.MaxSpecimenDate

UPDATE M
SET SpecimenDateRangeFlag = 1
FROM MigrationDubiousSpecimenMatches M
INNER JOIN #SpecimenDateRangeFlag S ON M.EtsId = S.LegacyId AND M.ReferenceLaboratoryNumber = S.ReferenceLaboratoryNumber

INSERT INTO MigrationDubiousSpecimenMatches(EtsId,ReferenceLaboratoryNumber, SpecimenDateRangeFlag)
SELECT DISTINCT S.LegacyId, S.ReferenceLaboratoryNumber, 1 FROM #SpecimenDateRangeFlag S
LEFT JOIN MigrationDubiousSpecimenMatches M ON M.EtsId = S.LegacyId AND M.ReferenceLaboratoryNumber = S.ReferenceLaboratoryNumber
WHERE M.EtsId IS NULL

 ------------------------------------------------------------------------------------------------------------
 --different NHS numbers
    select e.*,n.NhsNumber, ls.PatientNhsNumber into #DifferentNHS from [$(NTBS_Specimen_Matching)].dbo.EtsSpecimenMatch e
    inner join #NotificationsInScope n on n.EtsId = e.LegacyId
  inner join [$(NTBS_Specimen_Matching)].dbo.LabSpecimen ls on ls.ReferenceLaboratoryNumber = e.ReferenceLaboratoryNumber
  where Replace(NhsNumber,' ','') <> Replace(PatientNhsNumber,' ','')
  and NhsNumber not in ('','0000000000') and PatientNhsNumber not in ('','.') and PatientNhsNumber not like '%[A-Z]%'


  UPDATE M
SET NHSNumberDifferentFlag = 1
FROM MigrationDubiousSpecimenMatches M
INNER JOIN #DifferentNHS S ON M.EtsId = S.LegacyId AND M.ReferenceLaboratoryNumber = S.ReferenceLaboratoryNumber

INSERT INTO MigrationDubiousSpecimenMatches(EtsId,ReferenceLaboratoryNumber, NHSNumberDifferentFlag)
SELECT DISTINCT S.LegacyId, S.ReferenceLaboratoryNumber, 1 FROM #DifferentNHS S
LEFT JOIN MigrationDubiousSpecimenMatches M ON M.EtsId = S.LegacyId AND M.ReferenceLaboratoryNumber = S.ReferenceLaboratoryNumber
WHERE M.EtsId IS NULL
   ------------------------------------------------------------------------------------------------------------
 --matched to a denotified case
 --we are only going to migrate in fairly recent denotified cases so exclude notifications where the notification date is more than 18 months ago
  select e.* into #DenotifiedMatchFlag from [$(NTBS_Specimen_Matching)].dbo.EtsSpecimenMatch e
  inner join #NotificationsInScope n on n.EtsId = e.LegacyId
  inner join Record_CaseData cd on cd.EtsId = e.LegacyId
  inner join RecordRegister rr on rr.NotificationId = cd.NotificationId
  where rr.Denotified = 1 AND DATEADD(day, 548, rr.[NotificationDate]) > GETDATE()

UPDATE M
SET DenotifiedMatchFlag = 1
FROM MigrationDubiousSpecimenMatches M
INNER JOIN #DenotifiedMatchFlag S ON M.EtsId = S.LegacyId AND M.ReferenceLaboratoryNumber = S.ReferenceLaboratoryNumber

INSERT INTO MigrationDubiousSpecimenMatches(EtsId,ReferenceLaboratoryNumber, DenotifiedMatchFlag)
SELECT DISTINCT S.LegacyId, S.ReferenceLaboratoryNumber, 1 FROM #DenotifiedMatchFlag S
LEFT JOIN MigrationDubiousSpecimenMatches M ON M.EtsId = S.LegacyId AND M.ReferenceLaboratoryNumber = S.ReferenceLaboratoryNumber
WHERE M.EtsId IS NULL
  ------------------------------------------------------------------------------------------------------------
 --matched to a deleted draft
select n.LegacyId as ets_id,a.ReferenceLaboratoryNumber,n.AuditDelete,n.NotificationDate, SpecimenDate,n.Submitted,lr.OpieId,lr.AuditCreate,lr.AutoMatched,
p.Forename, p.Surname, p.DateOfBirth, p.NhsNumber, a.PatientForename, a.PatientSurname, a.PatientBirthDate, a.PatientNhsNumber, su.Email as CaseOwnerEmail
INTO #DeletedDraftFlag
FROM [$(ETS)].dbo.[Notification]  n
inner join [$(ETS)].dbo.LaboratoryResult lr on lr.NotificationId = n.Id
inner join [$(Labbase2)].dbo.Anonymised a on a.OpieId = lr.OpieId
inner join [$(Labbase2)].dbo.SpecimenResult sr on sr.LabDataID = a.LabDataID
left join [$(ETS)].dbo.Patient p on p.Id = n.PatientId
left join [$(ETS)].dbo.SystemUser su on su.Id = n.OwnerUserId

where (n.AuditDelete is not null ) and lr.AuditDelete is null and lr.OpieId is not null
and year(NotificationDate) in ( SELECT NotificationYear From vwNotificationYear)

UPDATE M
SET DeletedDraftFlag = 1
FROM MigrationDubiousSpecimenMatches M
INNER JOIN #DeletedDraftFlag S ON M.EtsId = S.ets_id AND M.ReferenceLaboratoryNumber = S.ReferenceLaboratoryNumber

INSERT INTO MigrationDubiousSpecimenMatches(EtsId,ReferenceLaboratoryNumber, DeletedDraftFlag)
SELECT DISTINCT S.ets_id, S.ReferenceLaboratoryNumber, 1 FROM #DeletedDraftFlag S
LEFT JOIN MigrationDubiousSpecimenMatches M ON M.EtsId = S.ets_id AND M.ReferenceLaboratoryNumber = S.ReferenceLaboratoryNumber
WHERE M.EtsId IS NULL


Drop table #DeletedDraftFlag
Drop table #DenotifiedMatchFlag
Drop table #DifferentNHS
Drop table #SpecimenDateRangeFlag
Drop table #SpecimenMultipleNotificationMatchFlag
 ------------------------------------------------------------------------------------------------------------

 UPDATE MigrationDubiousSpecimenMatches
 Set MigrationNotes = ReferenceLaboratoryNumber + ' (' +
CONCAT_WS(', ',REPLACE(cast([SpecimenDateRangeFlag] as varchar),'1','Specimen Date Range')
,REPLACE(cast([NHSNumberDifferentFlag] as varchar),'1','NHS Number Difference')
,REPLACE(cast([SpecimenMultipleNotificationMatchFlag] as varchar),'1','Specimen Multiple Notification Match')
,REPLACE(cast(DenotifiedMatchFlag as varchar),'1','Denotified Match')
,REPLACE(cast(DeletedDraftFlag as varchar),'1','Deleted Draft Match')) + ')'


 --Update Comments in MigrationRunResults field MigrationNotes
 --Review specimen match(es) to Isolate(s) [ReferenceLaboratoryNumber] (),[ReferenceLaboratoryNumber2]()
 	END TRY
	BEGIN CATCH
		THROW
	END CATCH
