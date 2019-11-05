USE [Relitix]
GO

/****** Object:  View [dbo].[tab2_prod_lead_assign_geo_2_v2]    Script Date: 11/5/2019 1:32:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO









CREATE view [dbo].[tab2_prod_lead_assign_geo_2_v2] as


---   7/21/2018   Added filter to limit closedates to 2011 - today
---	  7/28/2018	  Fixed filter to allow non-closed listings.
---   8/21/2018  Changed County to pull from LC_geo vs MLS entry (too many errors)
---   8/22/2018  Changed name back to CountyOrParrish so views would still work (oops)
---   11/2/2018  Added volume credit and sides for colist/cosell
---	  1/30/2019   Add field officeaddress1

select CloseDate
	,list_side
	,ListingContractDate
	,PropertyType
	,PropertySubType
	,cn.County as CountyOrParrish -- Changed to use geo table vs MLS county
	,lv.ListingKey
	,lv.SourceSystemID
	,lv.ClosePrice
	,lv.ListPrice
	,lv.volume_credit -- added
	,lv.sides  -- added
	,PostalCode
	,StandardStatus
	,o.OfficeName
	,o.OfficeCity
	,o.Company
	,o.Franchise
	,concat(a.MemberFullName,' ',a.sourcesystemid,'-',a.memberkey) as full_name_ID
	,ZNeighborhood
	,g.CensusPlace
	,iif(ISNULL(g.CensusPlace,'True') = 'True',CONCAT('Unincorporated ',cn.County_name),g.CensusPlace) as PlaceDescription
	,g.CBSAName
	,g.CBSAType
	,g.UAName
	,g.UAType
	,cn.State_name
	,Latitude
	,Longitude
	,GEOID
	,o.OfficeAddress1
from Listings_Combined_For_Volume lv
	join Relitix.dbo.Listings_Combined_Geo g
		on lv.listingkey = g.listingkey
			and lv.sourcesystemid = g.SourceSystemID
	join Relitix.dbo.Offices_Combined o
		on lv.office_key = o.officekey
			and lv.sourcesystemid = o.sourcesystemid
	join Relitix.dbo.Agents_Combined a
		on lv.agent_key = a.memberkey
			and lv.sourcesystemid = a.sourcesystemid
	join Relitix.dbo.Census_County_Names cn
		on g.CountyFP = cast(cn.CountyFP as varchar)
			and g.StateFP = cn.State_Num
where (closedate >= '2011-01-01' and closedate <= getdate())
	or (ListingContractDate >= '2011-01-01' and closedate is null)
	








GO


