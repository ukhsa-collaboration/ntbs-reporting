CREATE FUNCTION [dbo].[ufnGetServiceResponsible]
(
	@TimePeriod int,
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
			SELECT TOP 1 trans.TbServiceName
			FROM AllTransfers trans
			WHERE trans.NotificationId = @NotificationId
				AND trans.EventDate = DATEADD(DAY, -1, DATEADD(YEAR, @TimePeriod, @StartDate))
				AND trans.TransferType = 'TransferIn'
			ORDER BY EventDate DESC
			),
			(
			SELECT TOP 1 trans.TbServiceName
			FROM AllTransfers trans
			WHERE trans.NotificationId = @NotificationId
				AND trans.EventDate >= DATEADD(DAY, -1, DATEADD(YEAR, @TimePeriod, @StartDate))
				AND trans.TransferType = 'TransferOut'
			ORDER BY EventDate
			),
			@DefaultService
		)

	RETURN @ReturnValue
END
	
	
