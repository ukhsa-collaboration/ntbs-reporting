CREATE PROCEDURE [dbo].[uspGenerateLabMappings] AS
declare @Mappings as table
	 (
		FieldName nvarchar(100),
		ETSDisplayCode nvarchar(100),
		LabDisplayCode nvarchar(50),
		LabName nvarchar(100),
		auditcreate date,
		Description nvarchar(100)
	 )

if object_id('dbo.LabMappings','U') is not null 
begin    
	drop table LabMappings
end
	 insert into @Mappings
 SELECT LF.FieldName, EC.DisplayCode AS ETSDisplayCode, LC.DisplayCode AS LabDisplayCode,l.Name as LabName,LCM.AuditCreate as auditcreate,EC.Description
 
	 FROM  [$(ETS)].dbo.STM_LabCodeMapping AS LCM 
	  INNER JOIN [$(ETS)].dbo.STM_LabCode AS LC on LC.LabCodeID = LCM.LabCodeID 
	  INNER JOIN [$(ETS)].dbo.STM_ETSCode AS EC on EC.ETSCodeID = LCM.ETSCodeID
	  INNER JOIN [$(ETS)].dbo.STM_LabField LF on LF.LabFieldID = LCM.FieldID
	  inner join [$(ETS)].dbo.[Laboratory] l on l.Id= lcm.[LabID]
	  order by labname, ETSDisplayCode

select [FieldName]
      ,[ETSDisplayCode]
      ,[LabDisplayCode]
      ,[LabName]
      ,cast([auditcreate] as date) as auditcreate
      ,[Description] into LabMappings from (select * from @Mappings
union all
select distinct 'Organism',OrganismCode, OrganismCode, 'Cardiff',o.AuditCreate,t.OrganismType from [$(ETS)].dbo.STM_Organism o
inner join [$(ETS)].dbo.STM_OrganismType t on t.OrganismTypeID = o.OrganismTypeID and t.OrganismType = 'Atypical'
inner join [$(Labbase2)].dbo.Anonymised a on a.OrganismName = o.OrganismCode and ReferenceLaboratory = 'Cardiff' 
union all
select distinct 'Organism',OrganismCode, OrganismCode, 'Northern Ireland',o.AuditCreate,t.OrganismType from [$(ETS)].dbo.STM_Organism o
inner join [$(ETS)].dbo.STM_OrganismType t on t.OrganismTypeID = o.OrganismTypeID and t.OrganismType = 'Atypical'
inner join [$(Labbase2)].dbo.Anonymised a on a.OrganismName = o.OrganismCode and ReferenceLaboratory = 'Northern Ireland'
Union all
select distinct 'Organism',OrganismDisplayName, OrganismCode, 'NMRL',o.AuditCreate,t.OrganismType from [$(ETS)].dbo.STM_Organism o
inner join [$(ETS)].dbo.STM_OrganismType t on t.OrganismTypeID = o.OrganismTypeID and t.OrganismType = 'Atypical'
inner join [$(Labbase2)].dbo.Anonymised a on a.OrganismName = o.OrganismCode and ReferenceLaboratory = 'NMRL'
Union all
select distinct 'Organism',OrganismName, OrganismName, 'Birmingham',null,case when IsAtypicalOrganismRecord = 1 then 'Atypical' else 'MTB' end  from [$(Labbase2)].dbo.Anonymised where MergedRecord = 0 and ReferenceLaboratory = 'Birmingham' and IsAtypicalOrganismRecord = 1) a
where FieldName not in (
'General Practitioner Code',
'Hospital/Trust or Sender',
'LaboratoryName',
'PatientEthnicity',
'PatientSex',
'ReferenceLaboratory') and LabName in ('NMRL','Birmingham','Cardiff','Northern Ireland')
order by FieldName, LabName, ETSDisplayCode
GO