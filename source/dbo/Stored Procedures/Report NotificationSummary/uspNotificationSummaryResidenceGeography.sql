/***************************************************************************************************
Desc:    This is a legacy proc that used to serve the "Notification Summary" Power BI report.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspNotificationSummaryResidenceGeography] AS
	SET NOCOUNT ON

	BEGIN TRY
		DECLARE	@LoginGroups VARCHAR(500);
		EXEC dbo.uspGetAuthenticatedLoginGroupsAndType @LoginGroups OUTPUT;

		IF (@LoginGroups != '###')
		BEGIN
			SELECT DISTINCT
				-- Primary key:
				n.NotificationId AS 'Notification ID',
				-- Notification record:
				dbo.ufnMaskField(ag.AdGroupName, @LoginGroups, CAST(n.EtsId AS VARCHAR(200))) AS 'ETS id', -- WORKAROUND: Varchar for Power BI "See Records" functionality
				dbo.ufnMaskField(ag.AdGroupName, @LoginGroups, n.LtbrId) AS 'ID Original',
				n.NotificationDate AS 'Notification date',
				dbo.ufnMaskField(ag.AdGroupName, @LoginGroups, n.CaseManager) AS 'Case manager',
				dbo.ufnMaskField(ag.AdGroupName, @LoginGroups, n.Consultant) AS 'Consultant',
				dbo.ufnMaskField(ag.AdGroupName, @LoginGroups, n.Forename) AS 'Forename',
				dbo.ufnMaskField(ag.AdGroupName, @LoginGroups, n.Surname) AS 'Surname',
				dbo.ufnMaskField(ag.AdGroupName, @LoginGroups, n.NhsNumber) AS 'NHS Number',
				dbo.ufnMaskField(ag.AdGroupName, @LoginGroups, n.Sex) AS 'Sex',
				dbo.ufnMaskField(ag.AdGroupName, @LoginGroups, CAST(n.Age AS VARCHAR(200))) AS 'Age', -- WORKAROUND: Varchar for Power BI "See Records" functionality
				dbo.ufnMaskField(ag.AdGroupName, @LoginGroups, CONVERT(VARCHAR, n.DateOfBirth, 106)) AS 'Date of birth',
				dbo.ufnMaskField(ag.AdGroupName, @LoginGroups, n.Postcode) AS 'Postcode',
				dbo.ufnMaskField(ag.AdGroupName, @LoginGroups, n.NoFixedAbode) AS 'No fixed abode',
				-- Geographies:
				ISNULL(n.Hospital, 'Unknown') AS 'Hospital',
				ISNULL(n.LocalAuthority, 'Unknown') AS 'Local authority',
				ISNULL(n.ResidencePhec, 'Unknown') AS 'PHEC',
				-- Custom date formats:
				FORMAT(n.NotificationDate, 'yyyy') AS 'Notification Year',
				FORMAT(n.NotificationDate, 'yyyy/MM') AS 'Notification Month',
				CONCAT(FORMAT(n.NotificationDate, 'yyyy/'), REPLICATE('0', 2 - LEN(DATEPART(week, n.NotificationDate))), DATEPART(week, n.NotificationDate)) AS 'Notification Week',
				FORMAT(n.NotificationDate, 'yyyy/MM/dd') AS 'Notification Day'
			FROM dbo.ReusableNotification n WITH (NOLOCK)
				INNER JOIN dbo.Phec p ON p.PhecName = n.ResidencePhec
				INNER JOIN dbo.PhecAdGroup pa ON pa.PhecId = p.PhecId
				INNER JOIN dbo.AdGroup ag ON ag.AdGroupId = pa.AdGroupId
		END
	END TRY
	BEGIN CATCH
		--EXEC dbo.uspHandleException
	END CATCH
