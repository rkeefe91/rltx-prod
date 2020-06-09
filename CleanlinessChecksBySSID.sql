DECLARE @ListingsTableName VARCHAR(100),
@AgentsTableName VARCHAR(100),
@OfficesTableName VARCHAR(100),
@SSID INT,
@SourceSystemName VARCHAR(100)

--Must Set This Parameter
SET @SSID=12


SET @SourceSystemName=(SELECT System_Name FROM Source_System WHERE System_ID=@SSID)
SET @ListingsTableName='Listings_' + @SourceSystemName
SET @OfficesTableName='Offices_' + @SourceSystemName
SET @AgentsTableName='Agents_' + @SourceSystemName


--Latest Listing Table Counts By Year
EXEC('SELECT YEAR(ListingContractDate) As ListYear,COUNT(*) As RecCount FROM ' + @ListingsTableName + ' WHERE ListingContractDate IS NOT NULL GROUP BY YEAR(ListingContractDate) ORDER BY 1 DESC')

--Standard Status Check
--Counts by Status
EXEC('SELECT DISTINCT StandardStatus,COUNT(*) As RecCount FROM ' + @ListingsTableName + ' GROUP BY StandardStatus ORDER BY 2 DESC')
--Check to make sure all statuses are mapped to a RESO status
EXEC('SELECT StandardStatus,COUNT(*) As RecCount FROM ' + @ListingsTableName + ' WHERE StandardStatus NOT IN (SELECT StandardStatus FROM Lookups_StandardStatus) GROUP BY StandardStatus ORDER BY 2 DESC')

--Date Checks - listing related dates with values in the future
EXEC('SELECT ListingContractDate,COUNT(*) As RecCount FROM ' + @ListingsTableName + ' WHERE ListingContractDate IS NOT NULL AND ListingContractDate > GETDATE() GROUP BY ListingContractDate ORDER BY 1 DESC')
EXEC('SELECT CloseDate,COUNT(*) As RecCount FROM ' + @ListingsTableName + ' WHERE CloseDate IS NOT NULL AND ListingContractDate > GETDATE() GROUP BY CloseDate ORDER BY 1 DESC')
EXEC('SELECT ExpirationDate,COUNT(*) As RecCount FROM ' + @ListingsTableName + ' WHERE ExpirationDate IS NOT NULL AND ExpirationDate > GETDATE() GROUP BY ExpirationDate ORDER BY 1 DESC')
EXEC('SELECT WithdrawnDate,COUNT(*) As RecCount FROM ' + @ListingsTableName + ' WHERE WithdrawnDate IS NOT NULL AND WithdrawnDate > GETDATE() GROUP BY WithdrawnDate ORDER BY 1 DESC')
EXEC('SELECT PendingTimestamp,COUNT(*) As RecCount FROM ' + @ListingsTableName + ' WHERE PendingTimestamp IS NOT NULL AND PendingTimestamp > GETDATE() GROUP BY PendingTimestamp ORDER BY 1 DESC')
EXEC('SELECT StatusChangeTimestamp,COUNT(*) As RecCount FROM ' + @ListingsTableName + ' WHERE StatusChangeTimestamp IS NOT NULL AND StatusChangeTimestamp > GETDATE() GROUP BY StatusChangeTimestamp ORDER BY 1 DESC')

