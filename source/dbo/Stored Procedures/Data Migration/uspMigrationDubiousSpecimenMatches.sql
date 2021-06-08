CREATE PROCEDURE [dbo].[uspMigrationDubiousSpecimenMatches]

AS
BEGIN TRY
SET NOCOUNT ON


--Create backup of table so previous set of results remain available.
TRUNCATE TABLE MigrationDubiousSpecimenMatchesBackup

INSERT INTO MigrationDubiousSpecimenMatchesBackup 
SELECT * FROM MigrationDubiousSpecimenMatches

TRUNCATE TABLE MigrationDubiousSpecimenMatches

Create Table #NotificationsInScope (EtsId int, MinEventDate Date,MaxEventDate Date)
INSERT into #NotificationsInScope 

    select EtsId
   ,(Select Min(EDate) From (Values(SymptomOnsetDate),(FirstPresentationDate),(DiagnosisDate),(StartOfTreatmentDate),(NotificationDate)) as v (EDate)) as [MinEventDate]
   ,(Select Max(EDate) From (Values(SymptomOnsetDate),(FirstPresentationDate),(DiagnosisDate),(StartOfTreatmentDate),(NotificationDate),(TreatmentEndDate),(DateOfDeath),(MdrTreatmentDate)) as v (EDate)) as [MaxEventDate]
   from [$(NTBS_Specimen_Matching)].dbo.EtsSpecimenMatch e
  inner join Record_CaseData cd on cd.EtsId = e.LegacyId
  inner join RecordRegister rr on rr.NotificationId = cd.NotificationId
    where year(NotificationDate) in ( SELECT NotificationYear From vwNotificationYear)
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
/*specimen date is more than a year before the notification date

<MAYBE> specimen date is outside the allowable date range for the notification (i.e. too long after as well as too long before)
*/
   select e.* into #SpecimenDateRangeFlag from [$(NTBS_Specimen_Matching)].dbo.EtsSpecimenMatch e 
   inner join #NotificationsInScope n on n.EtsId = e.LegacyId
   where DATEDIFF(day,[SpecimenDate],MinEventDate)>365 and DATEDIFF(day,[SpecimenDate],MaxEventDate) > 365


 --needs fixing for date range

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
    select e.*,pd.NhsNumber, ls.PatientNhsNumber into #DifferentNHS from [$(NTBS_Specimen_Matching)].dbo.EtsSpecimenMatch e
    inner join #NotificationsInScope n on n.EtsId = e.LegacyId
  inner join Record_CaseData cd on cd.EtsId = e.LegacyId
  inner join Record_PersonalDetails pd on pd.NotificationId = cd.NotificationId
  inner join [$(NTBS_Specimen_Matching)].dbo.LabSpecimen ls on ls.ReferenceLaboratoryNumber = e.ReferenceLaboratoryNumber
  where Replace(NHSNumber,' ','') <> Replace(PatientNhsNumber,' ','')
  and NHSNumber not in ('','0000000000') and PatientNhsNumber not in ('','.') and PatientNhsNumber not like '%[A-Z]%'


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
      select e.* into #DenotifiedMatchFlag from [$(NTBS_Specimen_Matching)].dbo.EtsSpecimenMatch e
      inner join #NotificationsInScope n on n.EtsId = e.LegacyId
  inner join Record_CaseData cd on cd.EtsId = e.LegacyId
  inner join RecordRegister rr on rr.NotificationId = cd.NotificationId
  where rr.Denotified = 1

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
