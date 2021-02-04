CREATE PROCEDURE [dbo].[uspMigrationDubiousSpecimenMatches]

AS
------------------------------------------------------------------------------------------------------------
--where one specimen has been matched to two different notifications.
select distinct e.* into #SpecimenMultipleNotificationMatchFlag from EtsSpecimenMatch e
INNER JOIN (

--Find multimatches 
SELECT ReferenceLaboratoryNumber,COUNT(*) as Total
  FROM  [EtsSpecimenMatch]
  
  where year([EarliestMatchDate]) > (year(GETDATE())-3)

  or year([SpecimenDate]) > (year(GETDATE())-3)
  group by ReferenceLaboratoryNumber
  having COUNT(*) >1)  AS Q1 on Q1.ReferenceLaboratoryNumber = e.ReferenceLaboratoryNumber
 order by e.ReferenceLaboratoryNumber

INSERT INTO MigrationDubiousSpecimenMatches(EtsId,ReferenceLaboratoryNumber, SpecimenMultipleNotificationMatchFlag)
SELECT LegacyId,ReferenceLaboratoryNumber,1 FROM #SpecimenMultipleNotificationMatchFlag
------------------------------------------------------------------------------------------------------------
/*specimen date is more than a year before the notification date

<MAYBE> specimen date is outside the allowable date range for the notification (i.e. too long after as well as too long before)
*/
   select e.* into #SpecimenDateRangeFlag from EtsSpecimenMatch e
  inner join LegacyExtract l on l.EtsId = e.LegacyId
  where ABS(DATEDIFF(day,CaseReportDate,[SpecimenDate])) >365
  and
 ( year([EarliestMatchDate]) > (year(GETDATE())-3))

 --needs fixing for date range

UPDATE M
SET SpecimenDateRangeFlag = 1
FROM MigrationDubiousSpecimenMatches M
INNER JOIN #SpecimenMultipleNotificationMatchFlag S ON M.EtsId = S.LegacyId AND M.ReferenceLaboratoryNumber = S.ReferenceLaboratoryNumber

INSERT INTO MigrationDubiousSpecimenMatches(EtsId,ReferenceLaboratoryNumber, SpecimenDateRangeFlag)
SELECT S.LegacyId, S.ReferenceLaboratoryNumber, 1 FROM #SpecimenDateRangeFlag S
LEFT JOIN MigrationDubiousSpecimenMatches M ON M.EtsId = S.LegacyId AND M.ReferenceLaboratoryNumber = S.ReferenceLaboratoryNumber
WHERE M.EtsId IS NULL
 
 ------------------------------------------------------------------------------------------------------------
 --different NHS numbers
    select e.*,le.NHSNumber,ls.PatientNhsNumber from EtsSpecimenMatch e
  inner join LegacyExtract le on le.EtsId = e.LegacyId
  inner join LabSpecimen ls on ls.ReferenceLaboratoryNumber = e.ReferenceLaboratoryNumber
  where Replace(NHSNumber,' ','') <> Replace(PatientNhsNumber,' ','') 
  and NHSNumber not in ('','0000000000') and PatientNhsNumber not in ('','.') and PatientNhsNumber not like '%[A-Z]%'
  and (year([EarliestMatchDate]) > (year(GETDATE())-3)

  or year(e.[SpecimenDate]) > (year(GETDATE())-3))
   ------------------------------------------------------------------------------------------------------------
      select e.* into #DenotifiedMatchFlag from EtsSpecimenMatch e
  inner join LegacyExtract l on l.EtsId = e.LegacyId
  where l.Denotified = 'Yes'
  ------------------------------------------------------------------------------------------------------------
    select n.LegacyId as ets_id,a.ReferenceLaboratoryNumber,n.AuditDelete,n.NotificationDate, SpecimenDate,n.Submitted,lr.OpieId,lr.AuditCreate,lr.AutoMatched,
p.Forename,p.Surname,p.DateOfBirth,p.NhsNumber,a.PatientForename,a.PatientSurname,a.PatientBirthDate,a.PatientNhsNumber,su.Email as CaseOwnerEmail 
INTO #DeletedDraftFlag
FROM [$(ETS)].dbo.Notification  n
inner join [$(ETS)].dbo.LaboratoryResult lr on lr.NotificationId = n.id
inner join [$(Labbase2)].dbo.Anonymised a on a.OpieId = lr.OpieId
inner join [$(Labbase2)].dbo.SpecimenResult sr on sr.LabDataID = a.LabDataID
left join [$(ETS)].dbo.patient p on p.Id = n.PatientId
left join [$(ETS)].dbo.systemUser su on su.Id = n.OwnerUserId

where (n.AuditDelete is not null ) and lr.AuditDelete is null and lr.OpieId is not null
and (year(lr.AuditCreate) > (year(GETDATE())-3)
    or year([SpecimenDate]) > (year(GETDATE())-3))
 ------------------------------------------------------------------------------------------------------------