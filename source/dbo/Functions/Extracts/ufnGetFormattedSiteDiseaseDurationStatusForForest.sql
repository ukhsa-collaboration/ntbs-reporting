-- This function is used in PopulateForestExtract procedure only
-- Value for site disease duration status for Forest is either Yes or Empty String (when the status is No, Unknown or Null)
CREATE FUNCTION dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest
	(
		@durationStatus varchar(100)
	)
	RETURNS varchar(10) 
	AS
	BEGIN
		RETURN
		CASE @durationStatus WHEN 'Yes' THEN 'Yes' ELSE '' 
	END
END