/***************************************************************************************************
Desc:    Initial naive implementation to allow work on NTBS-835 to proceed. Schema is very much
		 subject to change.
         
**************************************************************************************************/

CREATE TABLE [dbo].[NotificationClusterMatch](
	[NotificationId] INT NOT NULL,
	[ClusterId] [NVARCHAR](20) NULL

	 CONSTRAINT [PK_NotificationClusterMatch] PRIMARY KEY CLUSTERED (
		[NotificationId] ASC
	)
)
GO
