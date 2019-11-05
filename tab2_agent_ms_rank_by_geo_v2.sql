USE [Relitix]
GO

/****** Object:  View [dbo].[tab2_agent_ms_rank_by_geo_v2]    Script Date: 11/1/2019 7:57:38 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





--  10/15/2018   Changed closeprice to volume_credit to reflect co/listed and sold properties
--	11/10/2018	 Uploaded to Relitix
--   9/6/2019	 Added "neighborhood in" language for ZN descriptions



ALTER VIEW [dbo].[tab2_agent_ms_rank_by_geo_v2]

as


with cte as (  --- Generate list of closings within date range
		select a.MemberFullName
			,a.MemberKey
			,concat(a.MemberFullName,' ',a.SourceSystemID,'-',a.MemberKey) as full_name_ID
			,lc.volume_credit as ClosePrice -- Changed to reflect co-listed/sold properties
			,g.CountyFP
			,g.StateFP
			,g.CensusPlace
			,g.ZNeighborhood
			,lc.SourceSystemID
		from Relitix_Dev.dbo.Listings_Combined_For_Volume lc
			join Relitix.dbo.Listings_Combined_Geo g
				on lc.ListingKey = g.ListingKey
					and lc.SourceSystemID = g.SourceSystemID
			join Relitix.dbo.Agents_Combined a
				on lc.agent_key = a.memberkey
					and a.SourceSystemID = lc.SourceSystemID
		where CloseDate >= dateadd(year,-1,getdate())
				and CloseDate < getdate()

				),
cte_muni as  (   -- Generate rank by municipality
			SELECT full_name_ID,
					 CensusPlace as GeoName,
					 'CensusPlace' as GeoType,
					 sum(ClosePrice) as total_closed_volume,
					 rank() OVER (PARTITION BY censusplace, sourcesystemid ORDER BY sum(ClosePrice) desc) as Muni_Rank
					 ,SourceSystemID
			from cte
			where censusplace is not null
			group by full_name_ID, censusplace, SourceSystemID
			),
cte_county as (-- Generate rank by county
			SELECT full_name_ID,
						c.County_name as GeoName,
						'County' as GeoType,
						sum(ClosePrice) as total_closed_volume,
						rank() OVER (PARTITION BY c.County_name, sourcesystemid ORDER BY sum(ClosePrice) desc) as Muni_Rank
						,SourceSystemID
			from cte
				join relitix.dbo.census_County_Names c
					on cte.CountyFP = c.CountyFP
						and c.State_num = cte.StateFP
			group by full_name_ID,c.County_name, SourceSystemID
				),
cte_nb as (-- Generate rank by Zillow Neighborhood

			SELECT full_name_ID,
						concat(ZNeighborhood, ' (Neighborhood in ',CensusPlace,')') as GeoName,
						'Neighborhood' as GeoType,
						sum(ClosePrice) as total_closed_volume,
						rank() OVER (PARTITION BY ZNeighborhood, CensusPlace, sourcesystemid ORDER BY sum(ClosePrice) desc) as Muni_Rank
						,SourceSystemID
			from cte
			where ZNeighborhood is not null
			group by full_name_ID,ZNeighborhood, CensusPlace, SourceSystemID

			)
SELECT *
from cte_county

UNION

SELECT *
from cte_muni

UNION

SELECT *
from cte_nb

--order by sourcesystemID, full_name_ID, Muni_Rank 






GO


