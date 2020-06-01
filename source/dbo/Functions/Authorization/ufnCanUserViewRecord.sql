CREATE FUNCTION [dbo].[ufnCanUserViewRecord] (
	@TreatmentPhec VARCHAR(500),
	@ResidencePhec VARCHAR(500),
	@Service VARCHAR(500)
) 
RETURNS INT
AS
	BEGIN
		DECLARE @LoginGroups VARCHAR(500)
		
		SELECT @LoginGroups = CONCAT('###',REPLACE(AdGroups, ',', '###'),'###') FROM [$(NTBS)].[dbo].[User]
				WHERE Username = SYSTEM_USER

		DECLARE @LoginType VARCHAR(1)
		SELECT @LoginType = ADGroupType
		FROM AdGroup
		WHERE CHARINDEX('###' + AdGroupName + '###', @LoginGroups) != 0

		DECLARE @Result BIT = 0;

		IF @LoginType = 'N'
			SET @Result = 1
		ELSE IF @LoginType = 'R'
			SET @Result = CASE WHEN EXISTS(SELECT * FROM
					(SELECT 
					dbo.[ufnIsAdGroupNameInLoginGroups] (ag.AdGroupName, @LoginGroups) IsAllowed
					FROM dbo.Phec p
					INNER JOIN dbo.PhecAdGroup pa ON pa.PhecId = p.PhecId
					INNER JOIN dbo.AdGroup ag ON ag.AdGroupId = pa.AdGroupId
					WHERE p.PhecName = @TreatmentPhec) isAllowedTable
				WHERE IsAllowed = 1) THEN 1 ELSE 0 END
		ELSE IF @LoginType = 'S'
			SET @Result = 
				CASE WHEN EXISTS(
					SELECT * FROM
						(SELECT 
						dbo.[ufnIsAdGroupNameInLoginGroups] (sag.AdGroupName, @LoginGroups) IsAllowed
						FROM dbo.Phec p
						LEFT JOIN TB_Service s on s.phecid = p.PhecId and s.TB_Service_Name = @Service
						LEFT JOIN dbo.ServiceAdGroup sa on sa.ServiceId = s.Serviceid 
						LEFT JOIN dbo.AdGroup sag on sag.AdGroupId = sa.AdGroupId and sag.ADGroupType = 'S'
						WHERE p.PhecName = @TreatmentPhec) isAllowedTable
					WHERE IsAllowed = 1) 
				THEN 1 ELSE 0 END

		RETURN @Result
	END