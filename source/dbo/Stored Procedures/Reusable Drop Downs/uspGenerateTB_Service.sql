/***************************************************************************************************
Desc:    This refreshes the TB_Service table based on the TB_Service table in the NTBS_R1_Geography_Staging database. It includes details of the Phec

Author:  PHE
		 Adil Mirza
**************************************************************************************************/
CREATE procedure [dbo].[uspGenerateTB_Service] as


if object_id('tempdb.dbo.#Service','U') is not null 
begin	
	drop table #Service
end

create table #Service (	
						Serviceid int IDENTITY(1,1) NOT NULL, 
						TB_Service_Code varchar(50) not null,
						TB_Service_Name varchar(150) not null,
						Phecid tinyint not null, 
						SortOrder tinyint not null,
						PHEC_Code [nvarchar](50) NOT NULL, 
						PhecName [nvarchar](50) NOT NULL)

insert into #Service (Phecid, SortOrder,PHEC_Code, PhecName,TB_Service_Code,TB_Service_Name)


 SELECT distinct Phecid, SortOrder,PHEC_Code, PhecName,s.TB_Service_Code,s.TB_Service_Name
  FROM [dbo].[Phec] p inner join 

  [$(NTBS_R1_Geography_Staging)].dbo.TB_Service_to_PHEC l on l.PHEC_Code = p.PhecCode
  inner join [$(NTBS_R1_Geography_Staging)].dbo.TB_Service s on s.TB_Service_Code = l.TB_Service_Code
   order by SortOrder,TB_Service_Name


truncate table TB_Service

SET IDENTITY_INSERT [dbo].[TB_Service] ON 
insert into dbo.TB_Service ([Serviceid]
      ,[TB_Service_Code]
      ,[TB_Service_Name]
      ,[Phecid]
      ,[SortOrder]
      ,[PHEC_Code]
      ,[PhecName]) select [Serviceid]
      ,[TB_Service_Code]
      ,[TB_Service_Name]
      ,[Phecid]
      ,[SortOrder]
      ,[PHEC_Code]
      ,[PhecName] from #Service order by Serviceid   
SET IDENTITY_INSERT [dbo].[TB_Service] OFF
GO

