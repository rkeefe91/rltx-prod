USE [Relitix]
GO

/****** Object:  View [dbo].[tab2_ap_1year_mma_change_sell_2]    Script Date: 11/5/2019 1:38:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE VIEW [dbo].[tab2_ap_1year_mma_change_sell_2] AS

WITH first_trans AS (
			SELECT lv.agent_key
					,lv.SourceSystemID
				,min(lv.StatusChangeTimestamp) as first_trans_date
			FROM Listings_Combined_For_Volume lv
			GROUP BY lv.agent_key, lv.SourceSystemID
				),
main_county AS (
			SELECT lv.agent_key
				,lv.SourceSystemID
				,lv.CountyOrParrish as primary_county
				,ROW_NUMBER() OVER(PARTITION BY lv.agent_key,lv.SourceSystemID ORDER BY count(lv.ListingKey) DESC) AS rn
			FROM Listings_Combined_For_Volume lv
			GROUP BY lv.agent_key, lv.SourceSystemID, lv.CountyOrParrish
				
				),
rc AS (
			SELECT a.ID
				,a.SourceSystemID
				,a.full_name_ID
				,b.[year]
				,b.[month]
				,b.Rev_last_12 as total_closed_volume
				,b.Rev_last_12 - a.Rev_last_12 as yrchange
				,CASE WHEN a.Rev_last_12 = 0 then 0
					ELSE (b.Rev_last_12 - a.Rev_last_12)/a.Rev_last_12 end as pct_change
				,CASE WHEN a.Rev_last_12 = 0 then 1
					ELSE 0 end zero_basis_flag
				,o.OfficeName
				,o.OfficeCity
				,o.OfficePostalCode
				,iif(o.Company IS NULL, 'Others',o.Company) as Company
				,iif(o.Franchise IS NULL, 'Other/independent',o.Franchise) as Franchise
			FROM tab_ap_rev_list_12mma_sell a
				JOIN tab_ap_rev_list_12mma_sell b
					ON a.ID = b.ID 
						AND a.[month] = b.[month] 
						AND a.[year] = (b.[year]-1)
						AND a.SourceSystemID  = b.SourceSystemID
				JOIN work2_most_recent_office mro
					ON a.ID = mro.MemberKey
						and a.SourceSystemID = mro.SourceSystemID
				JOIN Offices_Combined o
					ON o.OfficeKey = mro.OfficeKey
						and o.SourceSystemId = mro.SourceSystemID
			WHERE  a.[month] = DATEPART(MONTH,DATEADD(MONTH,-1,GetDate())) and a.[year] = (DATEPART(YEAR,DATEADD(MONTH,-1,GetDate()))-1)
		)
SELECT rc.ID
	,rc.SourceSystemID
	,rc.full_name_ID
	,rc.[year]
	,rc.[month]
	,rc.total_closed_volume
	,rc.yrchange
	,rc.pct_change
	,rc.zero_basis_flag
	,rc.OfficeName
	,rc.OfficeCity
	,rc.OfficePostalCode
	,rc.Company
	,rc.Franchise
	,first_trans.first_trans_date
	,main_county.primary_county
	,ac.MemberEmail
	,ac.MemberPreferredPhone
	,ac.SocialMediaTypeUrlOrId
FROM rc
	LEFT JOIN first_trans
		ON first_trans.agent_Key = rc.ID
			and first_trans.SourceSystemID = rc.SourceSystemID
	Left JOIN main_county
		ON main_county.agent_key = rc.ID
			and main_county.SourceSystemID = rc.SourceSystemID
	JOIN Agents_Combined ac
		ON rc.ID = ac.MemberKey
			and rc.SourceSystemID = ac.SourceSystemID
WHERE (main_county.rn = 1 OR main_county.rn IS NULL)
	AND first_trans.first_trans_date IS NOT NULL



GO


