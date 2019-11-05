USE [Relitix_Dev]
GO

/****** Object:  View [dbo].[Listings_Combined_For_Volume]    Script Date: 11/5/2019 12:27:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




/*
11/14/2018		Added coalesce term to colistagentofficekey
3/21/2019		Restricted to listings and sales 2011 and later
11/5/2019		Added primary_position field


*/


DROP VIEW [dbo].[Listings_Combined_For_Volume];
go


CREATE VIEW [dbo].[Listings_Combined_For_Volume] as




with cte as ( 

		SELECT ListingContractDate   --- Listing agent
			,CloseDate
			,StatusChangeTimestamp
			,ListingKey
			,SourceSystemID
			,PropertyType
			,PropertySubType
			,CountyOrParrish
			,ExpirationDate
			,PendingTimestamp
			,WithdrawnDate
			,ListPrice
			,ClosePrice
			,StandardStatus
			,PostalCode
			,ListAgentKey as agent_key
			,ListAgentOfficeKey as office_key
			,1 as list_side
			,iif(colistagentkey IS NULL,0,1) as colisted
			,NULL as cobuyer
			,1 as primary_position
			,iif(colistagentkey IS NULL,1,0.5) as sides
			,CancelationDate
		FROM Relitix.dbo.Listings_Combined
		WHERE ListAgentKey is not null
UNION

		SELECT ListingContractDate   -- Selling agent
			,CloseDate
			,StatusChangeTimestamp
			,ListingKey
			,SourceSystemID
			,PropertyType
			,PropertySubType
			,CountyOrParrish
			,ExpirationDate
			,PendingTimestamp
			,WithdrawnDate
			,ListPrice
			,ClosePrice
			,StandardStatus
			,PostalCode
			,BuyerAgentKey as agent_key
			,BuyerOfficeKey as office_key
			,0 as list_side
			,NULL as colisted
			,iif(cobuyeragentkey IS NULL,0,1) as cobuyer
			,1 as primary_position
			,iif(cobuyeragentkey IS NULL,1,0.5) as sides
			,CancelationDate
		FROM Relitix.dbo.Listings_Combined
		WHERE ClosePrice IS NOT NULL AND ClosePrice > 0 
UNION

		SELECT ListingContractDate
			,CloseDate
			,StatusChangeTimestamp
			,ListingKey
			,SourceSystemID
			,PropertyType
			,PropertySubType
			,CountyOrParrish
			,ExpirationDate
			,PendingTimestamp
			,WithdrawnDate
			,ListPrice
			,ClosePrice
			,StandardStatus
			,PostalCode
			,CoListAgentKey as agent_key
			,COALESCE(CoListOfficeKey,ListAgentOfficeKey) as office_key
			,1 as list_side
			,1 as colisted
			,NULL as cobuyer
			,0 as primary_position
			,0.5 as sides
			,CancelationDate
		FROM Relitix.dbo.Listings_Combined
		WHERE CoListAgentKey is not null
UNION
		SELECT ListingContractDate
			,CloseDate
			,StatusChangeTimestamp
			,ListingKey
			,SourceSystemID
			,PropertyType
			,PropertySubType
			,CountyOrParrish
			,ExpirationDate
			,PendingTimestamp
			,WithdrawnDate
			,ListPrice
			,ClosePrice
			,StandardStatus
			,PostalCode
			,CoBuyerAgentKey as agent_key
			,BuyerOfficeKey as office_key
			,0 as list_side
			,NULL as colisted
			,1 as cobuyer
			,0 as primary_position
			,0.5 as sides
			,CancelationDate
		FROM Relitix.dbo.Listings_Combined
		WHERE ClosePrice IS NOT NULL AND ClosePrice > 0 and CoBuyerAgentKey IS NOT NULL


		)

select CONCAT(a.MemberFullName,' ',a.SourceSystemID,'-',MemberKey) as full_name_ID
	,ListingContractDate
	,CloseDate
	,StatusChangeTimestamp
	,ListingKey
	,cte.SourceSystemID
	,PropertyType
	,PropertySubType
	,CountyOrParrish
	,ExpirationDate
	,PendingTimestamp
	,WithdrawnDate
	,ListPrice
	,ClosePrice
	,StandardStatus
	,PostalCode
	,agent_key
	,office_key
	,list_side
	,colisted
	,cobuyer
	,primary_position
	,sides
	,CancelationDate
	,cte.sides * cte.closeprice as volume_credit
from cte
	join relitix.dbo.Agents_Combined a
		on cte.agent_key = a.MemberKey
			and cte.SourceSystemID = a.SourceSystemID
where (cte.closedate >= '2011-01-01'
	or cte.listingcontractdate >= '2011-01-01')










GO


