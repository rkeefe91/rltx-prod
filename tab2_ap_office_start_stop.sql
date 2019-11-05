USE [Relitix_dev]
GO

/****** Object:  View [dbo].[tab2_ap_office_start_stop]    Script Date: 11/5/2019 12:23:52 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



---   11/5/2018   Added coalesce term to get rid of NULL officecity
---   11/5/2019   Blocked co-listed/co-sold properties from this analysis
---				  Added office address field
---				  Added coalesce term to company



DROP VIEW IF EXISTS [dbo].[tab2_ap_office_start_stop];
go


 
CREATE VIEW [dbo].[tab2_ap_office_start_stop]
AS




with cte_list as ( -- Min and max listcontractdate
			SELECT  agent_key
					,SourceSystemID
					,office_key
					,max(ListingContractDate) as max_ts
					,min(ListingContractDate) as min_ts
			FROM [Listings_Combined_For_Volume]
			WHERE agent_key IS NOT NULL 
					and ListingContractDate > '2011-01-01'
					and ListingContractDate < getdate()
					and List_side = 1
					and primary_position = 1
			GROUP BY agent_key, SourceSystemID, office_key
			),
cte_close as ( -- Min and max closedate
			SELECT  agent_key
					,SourceSystemID
					,office_key
					,max(CloseDate) as max_ts
					,min(CloseDate) as min_ts
			FROM [Listings_Combined_For_Volume]
			WHERE agent_key IS NOT NULL 
					and CloseDate > '2011-01-01'
					and CloseDate < getdate()
					and list_side = 0
					and primary_position = 1
			GROUP BY agent_key, SourceSystemID, office_key
			),
cte_all as (
/*	select * from cte_sct
		union all */
	select * from cte_list	
		union all
	select * from cte_close
			),
cte_maxmin as (
		select agent_key
				,cte_all.SourceSystemID
				,office_key
				,max(max_ts) as last_trans
				,min(min_ts) as first_trans
		from cte_all
		group by agent_key, cte_all.SourceSystemID, office_key
			)
SELECT agent_key
	,cte_maxmin.SourceSystemID
	,a.MemberFullName
	,concat(a.MemberFullName,' ',cte_maxmin.SourceSystemID,'-',agent_key) as full_name_ID
	,o.OfficeName
	,coalesce(o.OfficeAddress1,'Not listed') as OfficeAddress   -- Added address
	,coalesce(o.OfficeCity,'Not listed') as OfficeCity
	,o.OfficeKey
	,coalesce(o.Company,'Independent/Other') as Company 
	,o.OriginatingSystemName as SubSystem 
	,first_trans
	,last_trans
FROM cte_maxmin	
	left JOIN relitix.dbo.Offices_Combined o
		ON cte_maxmin.office_key = o.OfficeKey 
			and cte_maxmin.sourcesystemid = o.sourcesystemid
	left JOIN Relitix.dbo.Agents_Combined a
		ON cte_maxmin.agent_key = a.MemberKey
			and cte_maxmin.sourcesystemid = a.sourcesystemid
--ORDER BY sourcesystemid, agent_key, first_trans













GO


