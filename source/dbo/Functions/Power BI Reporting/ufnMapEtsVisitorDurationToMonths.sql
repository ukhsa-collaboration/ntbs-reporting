/*this is a copy of the same function in the migration database
so that we can convert ETS duration periods
to numbers for reporting*/

CREATE FUNCTION ufnMapEtsVisitorDurationToMonths(
    @etsVisitorDuration NVARCHAR(MAX)
)
RETURNS TINYINT AS
BEGIN
    RETURN CASE @etsVisitorDuration
        WHEN 'Less than a month' THEN 1
        WHEN 'Up to 3 months' THEN 3
        WHEN 'Up to 6 months' THEN 6
        WHEN 'Up to 12 months' THEN 12
        WHEN 'More than 12 months' THEN 12
        ELSE NULL 
    END
END
