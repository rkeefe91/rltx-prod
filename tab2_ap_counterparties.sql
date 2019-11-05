USE [Relitix]
GO

/****** Object:  View [dbo].[tab2_ap_counterparties]    Script Date: 11/5/2019 1:33:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[tab2_ap_counterparties]
AS


---		7/28/2018   Added filter to get rid of wierd dates

select 
		al.MemberKey as list_ID
		,l.SourcesystemID
		,concat(al.MemberFullName,' ',l.sourcesystemid,'-',al.MemberKey) as full_name_ID_list
		,ol.OfficeName as list_office_name
		,ol.OfficeCity as list_office_city_name
		,ol.Company as list_company
		,ab.MemberKey as sell_ID
		,concat(ab.MemberFullName,' ',l.sourcesystemid,'-',ab.MemberKey) as full_name_ID_sell
		,ob.OfficeName as sell_office_name
		,ob.OfficeCity as sell_office_city_name
		,ob.Company as sell_company
		,l.PostalCode as zip
		,l.ClosePrice
		,l.CloseDate
		,l.PropertyType
		,l.PropertySubType

from Listings_Combined l
	join Agents_Combined al
		on l.ListAgentKey = al.MemberKey
			and l.SourceSystemID = al.SourceSystemID
	join Agents_Combined ab   -- Full join because we only want two-sided transactions
		on l.BuyerAgentKey = ab.MemberKey
			and l.SourceSystemID = ab.SourceSystemID
	join Offices_Combined ol
		on l.ListAgentOfficeKey = ol.OfficeKey
			and l.sourcesystemid = ol.sourcesystemid
	join Offices_Combined ob
		on l.BuyerOfficeKey = ob.OfficeKey
			and l.sourcesystemid = ob.sourcesystemid
WHERE CloseDate >= '2011-01-01' 
		AND Closedate <= getdate()
		and closeprice is not null


GO


