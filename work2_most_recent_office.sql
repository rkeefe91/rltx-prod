USE [Relitix]
GO

/****** Object:  View [dbo].[work2_most_recent_office]    Script Date: 11/5/2019 1:39:21 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[work2_most_recent_office]
AS

with cte as (
		SELECT a.MemberKey
				,a.SourceSystemID
				,a.OfficeKey
				,a.OfficeName
				,a.ModificationTimestamp
				,ROW_NUMBER() OVER (PARTITION BY a.MemberKey, a.SourceSystemID ORDER BY a.ModificationTimestamp DESC) AS rn
		FROM Agents_Combined a
		)
SELECT cte.MemberKey
	,cte.SourceSystemID
	,cte.OfficeKey
	,cte.ModificationTimestamp
FROM cte
WHERE rn = 1

GO


