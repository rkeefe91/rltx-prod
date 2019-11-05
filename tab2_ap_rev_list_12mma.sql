USE [Relitix]
GO

/****** Object:  View [dbo].[tab2_ap_rev_list_12mma]    Script Date: 11/5/2019 1:37:23 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[tab2_ap_rev_list_12mma] as

select concat(a.MemberFullName,' ',a.sourcesystemid,'-',a.MemberKey) as full_name_ID,
		r.myDate,
		r.month,
		r.year,
		r.List_last_12,
		r.Rev_last_12,
		r.total_closed_volume,
		r.total_new_listings
from tab_ap_rev_list_12mma r
	join Agents_Combined a
		on r.ID = a.MemberKey
			and a.SourceSystemID = r.SourceSystemID

GO


