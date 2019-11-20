/***************************************************************************************************
Desc:    This contains the AD groups that have been imported into the SQL instance that NTBS R1 users
         must belong to to have record viewing access.

Author:  Public Health England
         Adil Mirza    <adil.mirza@phe.gov.uk>
**************************************************************************************************/

CREATE TABLE [dbo].[ServiceAdGroup] (
    [ServiceAdGroupId] TINYINT IDENTITY (1, 1) NOT NULL,
    [ServiceId]        TINYINT NOT NULL,
    [AdGroupId]        TINYINT NOT NULL,
    CONSTRAINT [PK_ServiceAdGroup] PRIMARY KEY CLUSTERED ([ServiceAdGroupId] ASC)
);
GO

CREATE NONCLUSTERED INDEX [IX_ServiceAdGroup_AdGroupId]
    ON [dbo].[ServiceAdGroup]([AdGroupId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_ServiceAdGroup_ServiceId]
    ON [dbo].[ServiceAdGroup]([ServiceId] ASC);
GO