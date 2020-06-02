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
	VALUES ('0-9'),
	('10-19'),
	('20-29'),
	('30-39'),
	('40-49'),
	('50-59'),
	('60-69'),
	('70-79'),
	('80-89'),
	('90+')

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
					WHEN n.Age BETWEEN 0 AND 9 THEN '0-9'
					WHEN n.Age BETWEEN 10 AND 19 THEN '10-19'
					WHEN n.Age BETWEEN 20 AND 29 THEN '20-29'
					WHEN n.Age BETWEEN 30 AND 39 THEN '30-39'
					WHEN n.Age BETWEEN 40 AND 49 THEN '40-49'
					WHEN n.Age BETWEEN 50 AND 59 THEN '50-59'
					WHEN n.Age BETWEEN 60 AND 69 THEN '60-69'
					WHEN n.Age BETWEEN 70 AND 79 THEN '70-79'
					WHEN n.Age BETWEEN 80 AND 89 THEN '80-89'
					WHEN n.Age > 90 THEN '90+'
				END AS AgeRange
			FROM ReusableNotification n WITH (NOLOCK)
			LEFT JOIN NotificationClusterMatch cluster ON cluster.NotificationId = n.NotificationId
			WHERE ClusterId = @ClusterId) notificationsWithAgeRange
		GROUP BY AgeRange) ageGroupings
	RIGHT JOIN #AgeRangeTempTable ar ON ar.AgeRange = ageGroupings.AgeRange

	DROP TABLE #AgeRangeTempTable
END