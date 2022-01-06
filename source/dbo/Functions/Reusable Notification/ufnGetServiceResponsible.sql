CREATE FUNCTION [dbo].[ufnGetServiceResponsible]
(
	@NumberOfYears int,
	@NotificationId int,
	@StartDate DATETIME,
	@DefaultService NVARCHAR(150)
)
RETURNS NVARCHAR(150)
AS
BEGIN
	DECLARE @ReturnValue NVARCHAR(150) = NULL

	SET @ReturnValue = 
		COALESCE (
			(
			SELECT TOP 1 tout.TbServiceName
			FROM TransfersOut tout
			WHERE tout.NotificationId = @NotificationId
				AND tout.EventDate > DATEADD(DAY, -1, DATEADD(YEAR, @NumberOfYears, @StartDate))
			ORDER BY EventDate
			),
			@DefaultService
		)

	RETURN @ReturnValue
END
	
	
