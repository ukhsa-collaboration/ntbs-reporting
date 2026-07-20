CREATE VIEW [dbo].[vwUnmatchedSpecimensRelatedNotificationsList]
	AS 

  select us.ReferenceLaboratoryNumber, STRING_AGG(NotificationID,', ') WITHIN GROUP (ORDER BY NotificationID) AS RelatedNotificationsExlPoorQuality 
  FROM UnmatchedSpecimens us
  INNER JOIN UnmatchedSpecimensLinkedNotifications usln on usln.ReferenceLaboratoryNumber = us.ReferenceLaboratoryNumber
  where usln.NotificationLinkReason <> 'PoorQualityMatch'
  GROUP BY us.ReferenceLaboratoryNumber
