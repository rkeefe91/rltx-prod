use relitix;
go


CREATE VIEW tab_LCV as

SELECT agent_key
	,SourceSystemID as[Source System ID]
	,full_name_ID
	,PropertyType as [Property Type]
	,PropertySubType as [Property Sub Type]
	,listingkey as [Listing Key]
	,list_side
	,ListingContractDate as [Listing Contract Date]
	,closedate as [Close Date]
	,ClosePrice as [Close Price]
	,volume_credit
	,sides
from relitix.dbo.Listings_Combined_For_Volume
