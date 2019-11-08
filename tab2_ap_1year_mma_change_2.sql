USE [Relitix]
GO

/****** Object:  View [dbo].[tab2_ap_1year_mma_change_2]    Script Date: 11/5/2019 1:34:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO









CREATE VIEW [dbo].[tab2_ap_1year_mma_change_2] AS


---     8/5/18		Added coalesce clause to memberpreferredphone to address issue in SSID =7 where that field is all NULL
---		11/10/2018	Uploaded to prod
---		11/15/2018	Added additional fields to unscrew the tableau sheets
---		12/6/2018	Added List and Sell side pct columns
---		1/7/2019	Added Franchise column
---		4/8/2019 - Added OfficeKey to be used in further office metric calculations on push master table
---		6/28/2019 - Added new phone number and FN/LN columns to be used in push master table
---		9/6/2019 - Added join to Agents_Combined_Extended to populate missing emails and phone numbers where applicable
---		11/7/2019 - Added List_last_12 column for use in monthly_push_master


WITH first_trans AS (
			SELECT lv.agent_key
					,lv.SourceSystemID
					,min(   coalesce( iif(list_side = 1, listingcontractdate, NULL) ,closedate,  statuschangetimestamp)
						) as first_trans_date
			FROM Relitix.dbo.Listings_Combined_For_Volume lv
			GROUP BY lv.agent_key, lv.SourceSystemID
				),
main_county AS (
			SELECT lv.agent_key
				,lv.SourceSystemID
				,CONCAT(cn.County_name,', ',State_name) as primary_county
				,ROW_NUMBER() OVER(PARTITION BY lv.agent_key,lv.SourceSystemID ORDER BY count(lv.ListingKey) DESC) AS rn
			FROM Relitix.dbo.Listings_Combined_For_Volume lv
				join Relitix.dbo.Listings_Combined_Geo g
					on lv.ListingKey = g.ListingKey
						and lv.SourceSystemID = g.SourceSystemID
				join Relitix.dbo.Census_County_Names cn
					on g.CountyFP = cn.CountyFP
						and g.StateFP = cn.State_Num
			GROUP BY lv.agent_key, lv.SourceSystemID, CONCAT(cn.County_name,', ',State_name)
				
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
	,rc.Actives
	,rc.closed_sides
	,rc.total_transactions
	,rc.sides_last_12
	,rc.transactions_last_12
	,rc.ListSidePct
	,rc.SellSidePct
	,rc.ListSidePct_last_12
	,rc.SellSidePct_last_12
	,CASE WHEN rc.Company IS NULL THEN 'Others'
		ELSE rc.Company END as Company
	,first_trans.first_trans_date
	,main_county.primary_county
	,coalesce(ac.MemberEmail,ex.Email) As MemberEmail
	,coalesce(ac.MemberPreferredPhone, ac.MemberMobilePhone, ac.MemberHomePhone,ex.CellPhone) as MemberPreferredPhone
	,ac.SocialMediaTypeUrlOrId
	,CASE WHEN rc.Franchise IS NULL THEN 'Others'
		ELSE rc.Franchise END as Franchise,
		rc.OfficeAddress1,
		rc.OfficeKey,
		ac.MemberFirstName,
		ac.MemberLastName,
		ac.MemberDirectPhone,
		ac.MemberFax,
		ac.MemberHomePhone,
		coalesce(ac.MemberMobilePhone,ex.CellPhone) As MemberMobilePhone,
		coalesce(ac.MemberOfficePhone,ex.OfficePhone) As MemberOfficePhone,
		rc.List_Last_12
FROM tab2_ap_1year_mma_change rc
	LEFT JOIN first_trans
		ON first_trans.agent_Key = rc.ID
			and first_trans.SourceSystemID = rc.SourceSystemID
	Left JOIN main_county
		ON main_county.agent_key = rc.ID
			and main_county.SourceSystemID = rc.SourceSystemID
	JOIN Relitix.dbo.Agents_Combined ac
		ON rc.ID = ac.MemberKey
			and rc.SourceSystemID = ac.SourceSystemID
	LEFT JOIN
		Relitix.dbo.Agents_Combined_Extended ex
		ON ac.MemberKey=ex.MemberKey and ac.SourceSystemID=ex.SourceSystemID
WHERE (main_county.rn = 1 OR main_county.rn IS NULL)
	AND first_trans.first_trans_date IS NOT NULL













GO


