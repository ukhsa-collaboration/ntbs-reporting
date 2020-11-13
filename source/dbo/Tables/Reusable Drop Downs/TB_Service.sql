/***************************************************************************************************
Desc:    This contains the TB Service drop-down values.

Author:  PHE
		Adil Mirza
**************************************************************************************************/

CREATE TABLE [dbo].[TB_Service] (
    [Serviceid]       INT           IDENTITY (1, 1) NOT NULL,
    [TB_Service_Code] VARCHAR (50)  NOT NULL,
    [TB_Service_Name] VARCHAR (150) NOT NULL,
    [phecid]          TINYINT       NOT NULL,
    [SortOrder]       TINYINT       NOT NULL,
    [PHEC_Code]       NVARCHAR (50) NOT NULL,
    [PhecName]        NVARCHAR (50) NOT NULL,
    [IsLegacy] BIT NULL, 
    CONSTRAINT [PK_Service] PRIMARY KEY CLUSTERED ([Serviceid] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_Phec_Phec_Code]
    ON [dbo].[TB_Service]([PHEC_Code] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_Phec_phecid]
    ON [dbo].[TB_Service]([phecid] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_Phec_PhecName]
    ON [dbo].[TB_Service]([PhecName] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_Phec_SortOrder]
    ON [dbo].[TB_Service]([SortOrder] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_Phec_TB_Service_Code]
    ON [dbo].[TB_Service]([TB_Service_Code] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_Phec_TB_Service_Name]
    ON [dbo].[TB_Service]([TB_Service_Name] ASC);
GO