CREATE SCHEMA PropertyAnalytics;
-- View: PropertyAnalytics.PropertyTypeCount
CREATE VIEW PropertyAnalytics.PropertyTypeCount AS
SELECT PropertyType, COUNT(*) AS NumberOfEachType
FROM Properties
GROUP BY PropertyType;
-- View: PropertyAnalytics.PropertyTypeLocationCount
CREATE VIEW PropertyAnalytics.PropertyTypeLocationCount AS
SELECT PropertyType, concat(latitude,'',longitude) as location, COUNT(*) AS TotalProperties
FROM Properties
GROUP BY PropertyType, concat(latitude,'',longitude) ;

-- View: PropertyAnalytics.AvgPricePerSqm
CREATE VIEW PropertyAnalytics.AvgPricePerSqm AS
SELECT concat(latitude,'',longitude) as location, AVG(CAST(taxvaluedollarcnt AS FLOAT) / lotsizesquarefeet) AS AvgPricePerSqm
FROM Properties
GROUP BY concat(latitude,'',longitude) ;

-- View: PropertyAnalytics.PropertyTypeDistribution
CREATE VIEW PropertyAnalytics.PropertyTypeDistribution AS
SELECT 
    PropertyType,
    COUNT(*) AS TotalProperties,
    CONCAT(FORMAT(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), '0.#'), '%') AS Percentage
FROM Properties
GROUP BY PropertyType;

-- View: PropertyAnalytics.Top10Expensive
CREATE VIEW PropertyAnalytics.Top10Expensive AS
SELECT TOP 10 taxvaluedollarcnt, PropertyType
FROM Properties
ORDER BY taxvaluedollarcnt DESC;

-- View: PropertyAnalytics.Top10Visited
CREATE VIEW PropertyAnalytics.Top10Visited AS
SELECT TOP 10 V.PropertyID, P.ParcelID, COUNT(*) AS MostVisited
FROM Properties P
JOIN Visits V ON P.ParcelID = V.PropertyID
GROUP BY V.PropertyID, P.ParcelID
ORDER BY MostVisited DESC;

-- View: SalesPerformance.MonthlySales
CREATE SCHEMA SalesPerformance;
CREATE VIEW SalesPerformance.MonthlySales AS
SELECT FORMAT(SaleDate, 'yyyy-MM') AS Month, SUM(SalePrice) AS TotalSales
FROM Sales
GROUP BY FORMAT(SaleDate, 'yyyy-MM');

-- View: SalesPerformance.QuarterlySales
CREATE VIEW SalesPerformance.QuarterlySales AS
SELECT CONCAT(YEAR(SaleDate), '-Q', DATEPART(QUARTER, SaleDate)) AS Quarter, SUM(SalePrice) AS TotalSales
FROM Sales
GROUP BY YEAR(SaleDate), DATEPART(QUARTER, SaleDate);

-- View: SalesPerformance.YearlySales
CREATE VIEW SalesPerformance.YearlySales AS
SELECT YEAR(SaleDate) AS Yearly, SUM(SalePrice) AS TotalSales
FROM Sales
GROUP BY YEAR(SaleDate);

-- View: SalesPerformance.AvgSalePerProperty
CREATE VIEW SalesPerformance.AvgSalePerProperty AS
SELECT P.ParcelID, AVG(S.SalePrice) AS AverageSales
FROM Sales S
JOIN Properties P ON S.PropertyID = P.ParcelID
GROUP BY P.ParcelID;

-- View: Conversion.PropertyConversionRate
CREATE SCHEMA Conversion;
CREATE VIEW Conversion.PropertyConversionRate AS
SELECT 
  V.PropertyID,
  COUNT(DISTINCT S.SaleID) AS TotalSales,
  COUNT(DISTINCT V.VisitID) AS TotalVisits,
  CONCAT(FORMAT(CAST(COUNT(DISTINCT S.SaleID) AS FLOAT) / NULLIF(COUNT(DISTINCT V.VisitID), 0), '0.#'), '%') AS ConversionRate
FROM Visits V
LEFT JOIN Sales S ON V.PropertyID = S.PropertyID
GROUP BY V.PropertyID;

-- View: Conversion.AgentConversionRate
CREATE VIEW Conversion.AgentConversionRate AS
SELECT 
  V.AgentID,
  COUNT(DISTINCT S.SaleID) AS TotalSales,
  COUNT(DISTINCT V.VisitID) AS TotalVisits,
  CONCAT(FORMAT(CAST(COUNT(DISTINCT S.SaleID) AS FLOAT) / NULLIF(COUNT(DISTINCT V.VisitID), 0), '0.#'), '%') AS ConversionRate
FROM Visits V
LEFT JOIN Sales S ON V.AgentID = S.AgentID
GROUP BY V.AgentID;

-- View: Conversion.DaysOnMarket
CREATE VIEW Conversion.DaysOnMarket AS
SELECT 
  S.PropertyID,
  MIN(V.VisitDate) AS FirstVisitDate,
  S.SaleDate,
  DATEDIFF(DAY, MIN(V.VisitDate), S.SaleDate) AS DaysOnMarket
FROM Sales S
JOIN Visits V ON S.PropertyID = V.PropertyID
GROUP BY S.PropertyID, S.SaleDate;

-- View: AgentPerformance.SalesPerAgent
CREATE SCHEMA AgentPerformance;
CREATE VIEW AgentPerformance.SalesPerAgent AS
SELECT CONCAT(A.FirstName, ' ', A.LastName) AS FullName, COUNT(S.SaleID) AS SalesPerAgent
FROM Sales S
JOIN Agents A ON S.AgentID = A.AgentID
GROUP BY CONCAT(A.FirstName, ' ', A.LastName);

-- View: AgentPerformance.ClientsPerAgent
CREATE VIEW AgentPerformance.ClientsPerAgent AS
SELECT CONCAT(A.FirstName, ' ', A.LastName) AS FullName, V.AgentID, COUNT(DISTINCT V.VisitID) AS NumberOfClients
FROM Visits V
JOIN Agents A ON V.AgentID = A.AgentID
GROUP BY V.AgentID, CONCAT(A.FirstName, ' ', A.LastName);

-- View: AgentPerformance.AvgSalesPerAgent
CREATE VIEW AgentPerformance.AvgSalesPerAgent AS
SELECT A.AgentID, CONCAT(A.FirstName, ' ', A.LastName) AS FullName, COUNT(S.SaleID) AS TotalSales, AVG(S.SalePrice) AS AvgSales
FROM Sales S
JOIN Agents A ON S.AgentID = A.AgentID
GROUP BY A.AgentID, CONCAT(A.FirstName, ' ', A.LastName);

-- View: ClientEngagement.VisitsPerClient
CREATE SCHEMA ClientEngagement;
CREATE VIEW ClientEngagement.VisitsPerClient AS
SELECT V.ClientID, CONCAT(C.FirstName, ' ', C.LastName) AS FullName, COUNT(V.PropertyID) AS NumOfProperty
FROM Visits V
JOIN Clients C ON V.ClientID = C.ClientID
GROUP BY V.ClientID, CONCAT(C.FirstName, ' ', C.LastName);

-- View: ClientEngagement.TopClientsBySales
CREATE VIEW ClientEngagement.TopClientsBySales AS
SELECT TOP 10 C.ClientID, CONCAT(C.FirstName, ' ', C.LastName) AS FullName, COUNT(S.SaleID) AS TotalPurchases, SUM(S.SalePrice) AS TotalSales
FROM Sales S
JOIN Clients C ON S.ClientID = C.ClientID
GROUP BY C.ClientID, CONCAT(C.FirstName, ' ', C.LastName)
ORDER BY TotalSales DESC;

-- View: ClientEngagement.ClientType
CREATE VIEW ClientEngagement.ClientType AS
SELECT S.ClientID, CONCAT(C.FirstName, ' ', C.LastName) AS FullName, COUNT(S.ClientID) AS NumClients,
  CASE 
  WHEN COUNT(S.ClientID) = 1 THEN 'First-time'
  WHEN COUNT(S.ClientID) > 1 THEN 'Repeat-buyers'
  ELSE 'Not-Sale' END AS NumOfSales
FROM Clients C
JOIN Sales S ON C.ClientID = S.ClientID
GROUP BY S.ClientID, CONCAT(C.FirstName, ' ', C.LastName);

-- View: LocationInsights.VisitsByCity
CREATE VIEW LocationInsights.VisitsByCity AS
SELECT P.Location, COUNT(V.VisitID) AS NumOfVisits
FROM Visits V
JOIN Properties P ON V.PropertyID = P.ParcelID
GROUP BY P.Location;
