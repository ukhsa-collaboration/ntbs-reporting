/***************************************************************************************************
Desc:    This contains the AD groups that have been imported into the SQL instance that NTBS R1 users
         must belong to to have record viewing access.


         
**************************************************************************************************/

CREATE TABLE [dbo].[AdGroup] (
    [AdGroupId]      TINYINT       IDENTITY (1, 1) NOT NULL,
    [AdGroupName]    VARCHAR (200) NOT NULL,
    [IsNationalTeam] TINYINT       NOT NULL,
    [ADGroupType]    NVARCHAR (1)  NULL,
    CONSTRAINT [PK_AdGroup] PRIMARY KEY CLUSTERED ([AdGroupId] ASC)
);
GO
