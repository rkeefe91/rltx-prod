USE [Relitix]
GO

/****** Object:  View [dbo].[tab_colist_cosell]    Script Date: 11/5/2019 1:33:50 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[tab_colist_cosell] AS

/*
	3/21/2019	RK	Created
*/

with cte as (
			select listagentkey as primary_key,
				colistagentkey as co_key,
				1 as list,
				1 as prime,
				listingkey,
				sourcesystemid,
				listingcontractdate as eff_date
			from Listings_Combined l
				where colistagentkey IS NOT NULL
	UNION
				select colistagentkey as primary_key,
				listagentkey as co_key,
				1 as list,
				0 as prime,
				listingkey,
				sourcesystemid,
				listingcontractdate as eff_date
			from Listings_Combined l
				where colistagentkey IS NOT NULL
	UNION
			select buyeragentkey as primary_key,
				cobuyeragentkey as co_key,
				0 as list,
				1 as prime,
				listingkey,
				sourcesystemid,
				closedate as eff_date
			from Listings_Combined l
				where cobuyeragentkey IS NOT NULL
					and closedate >= '2011-01-01'
	UNION
			select cobuyeragentkey as primary_key,
				buyeragentkey as co_key,
				0 as list,
				0 as prime,
				listingkey,
				sourcesystemid,
				closedate as eff_date
			from Listings_Combined l
				where cobuyeragentkey IS NOT NULL
					and closedate >= '2011-01-01'
				)
select CONCAT(ap.MemberFullName,' ',ap.SourceSystemID,'-',ap.MemberKey) as full_name_ID_primary
	,CONCAT(ac.MemberFullName,' ',ac.SourceSystemID,'-',ac.MemberKey) as full_name_ID_co
	,cte.*
from cte
	join relitix.dbo.Agents_Combined ap
		on cte.primary_key = ap.MemberKey
			and cte.SourceSystemID = ap.SourceSystemID
	join relitix.dbo.Agents_Combined ac
		on cte.co_key = ac.MemberKey
			and cte.SourceSystemID = ac.SourceSystemID
GO


