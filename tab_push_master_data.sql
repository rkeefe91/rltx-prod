USE [Relitix]
GO

/****** Object:  View [dbo].[tab_push_master_data]    Script Date: 11/11/2019 1:51:39 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[tab_push_master_data] AS

	-- 8/27/2019   Created

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
	,rc.first_trans_date
	,rc.primary_county
	,MemberEmail
	,MemberPreferredPhone
	,SocialMediaTypeUrlOrId
	,CASE WHEN rc.Franchise IS NULL THEN 'Others' ELSE rc.Franchise END as Franchise,
	rc.OfficeAddress1,
	rc.OfficeKey,
	MemberFirstName,
	MemberLastName,
	MemberDirectPhone,
	MemberFax,
	MemberHomePhone,
	MemberMobilePhone,
	MemberOfficePhone
	FROM monthly_push_master rc
	WHERE total_closed_volume <> 0 OR yrchange <>0

GO


