CREATE PROCEDURE [dbo].[uspGetAgeStatsBySex]
(
	@ClusterId VARCHAR(200)
)
AS
BEGIN
	CREATE TABLE #AgeRangeTempTable
	(
		AgeRange VARCHAR(10)
	)

	INSERT INTO #AgeRangeTempTable
	VALUES 
		('0-14'),
		('15-44'),
		('45-64'),
		('65+')

	SELECT
		ar.AgeRange,
		ISNULL(ageGroupings.FemaleCount, 0) AS FemaleCount,
		ISNULL(ageGroupings.MaleCount, 0) AS MaleCount
	FROM (
		SELECT
			AgeRange,
			SUM(CASE Sex WHEN 'Male' THEN 1 ELSE 0 END) AS MaleCount,
			SUM(CASE Sex WHEN 'Female' THEN 1 ELSE 0 END) AS FemaleCount
		FROM (
			SELECT
				n.NotificationId,
				n.Sex,
				CASE
					WHEN n.Age BETWEEN 0 AND 14 THEN '0-14'
					WHEN n.Age BETWEEN 15 AND 44 THEN '15-44'
					WHEN n.Age BETWEEN 45 AND 64 THEN '45-64'
					WHEN n.Age >= 65 THEN '65+'
				END AS AgeRange
			FROM ReusableNotification n WITH (NOLOCK)
			LEFT JOIN NotificationClusterMatch cluster ON cluster.NotificationId = (CASE WHEN n.NtbsId IS NULL THEN n.EtsId ELSE n.NtbsId END)
			WHERE ClusterId = @ClusterId) notificationsWithAgeRange
		GROUP BY AgeRange) ageGroupings
	RIGHT JOIN #AgeRangeTempTable ar ON ar.AgeRange = ageGroupings.AgeRange

	DROP TABLE #AgeRangeTempTable
END