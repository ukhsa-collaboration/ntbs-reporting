CREATE FUNCTION dbo.ufnGetSiteDiseaseDurationStatus
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