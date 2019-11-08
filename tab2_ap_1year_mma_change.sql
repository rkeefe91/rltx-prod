USE [Relitix]
GO

/****** Object:  View [dbo].[tab2_ap_1year_mma_change]    Script Date: 11/5/2019 1:36:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO













CREATE VIEW [dbo].[tab2_ap_1year_mma_change]
AS

-- 5/8/2018 Changed date to look to two months prior before the 11th of the month.
-- 11/6/2018 - Added additional columns to be used in push table generation
-- 12/6/2018 - Added list and sell side pct columns
-- 4/8/2019 - Added OfficeKey to be used in further office metric calculations on push master table
-- 4/10/2019 - Changed to use work_most_recent_office table to tag agents in correct office
-- 6/26/2019 - Changed to use the agent record to tag agent office correctly.
-- 11/7/2019 - Added List_last_12 column for use in monthly_push_master

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
	,o.Company
	,b.actives
	,b.closed_sides
	,b.total_transactions
	,b.sides_last_12
	,b.transactions_last_12
	,b.ListSidePct
	,b.SellSidePct
	,b.ListSidePct_last_12
	,b.SellSidePct_last_12
	,o.Franchise
	,o.OfficeAddress1
	,o.OfficeKey
	,b.List_last_12
FROM tab_ap_rev_list_12mma a
	JOIN tab_ap_rev_list_12mma b
		ON a.ID = b.ID 
			AND a.SourceSystemID = b.SourceSystemID
			AND a.[month] = b.[month] 
			AND a.[year] = (b.[year]-1)
	JOIN relitix.dbo.Agents_Combined ac
		on a.ID = ac.memberkey
			and a.sourcesystemid = ac.sourcesystemid
	JOIN Relitix.dbo.Offices_Combined o
		ON o.OfficeKey = ac.officekey
			and o.SourceSystemID = ac.sourcesystemid
WHERE a.[month] = DATEPART(MONTH,DATEADD(MONTH,-1, DATEADD(DAY,-2,  GetDate()))) and a.[year] = DATEPART(YEAR,DATEADD(MONTH,-1, DATEADD(DAY,-2,  GetDate())))-1
--DATEPART(MONTH,DATEADD(MONTH,-1, DATEADD(DAY,-9,  GetDate()))) and a.[year] = DATEPART(YEAR,DATEADD(MONTH,-1, DATEADD(DAY,-9,  GetDate())))-1
--a.[month] = DATEPART(MONTH,DATEADD(MONTH,-1, DATEADD(DAY,-7,  GetDate()))) and a.[year] = DATEPART(YEAR,DATEADD(MONTH,-1, DATEADD(DAY,-7,  GetDate())))-1

--ORDER BY b.Rev_last_12 DESC























GO


