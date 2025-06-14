-- 1. Duplicate parcelid (المفروض يكون Primary Key ومفيش تكرار، بس للتأكيد)
SELECT parcelid, COUNT(*) 
FROM Properties 
GROUP BY parcelid 
HAVING COUNT(*) > 1;

-- 2. Properties with invalid sizes or prices
-- لو عندك أعمدة بتقيس المساحة أو السعر مثلاً:
SELECT * 
FROM Properties 
WHERE 
    TRY_CAST(calculatedfinishedsquarefeet AS FLOAT) <= 0 
    OR TRY_CAST(structuretaxvaluedollarcnt AS FLOAT) <= 0 
    OR TRY_CAST(taxvaluedollarcnt AS FLOAT) <= 0;

-- 3. Properties with invalid lat/long
SELECT * 
FROM Properties 
WHERE 
    TRY_CAST(latitude AS FLOAT) IS NULL 
    OR TRY_CAST(longitude AS FLOAT) IS NULL;

-- 4. Properties with missing bedrooms or bathrooms
SELECT * 
FROM Properties 
WHERE 
    TRY_CAST(bedroomcnt AS INT) IS NULL 
    OR TRY_CAST(bathroomcnt AS INT) IS NULL;

-- 5. Properties with yearbuilt in the future
SELECT * 
FROM Properties 
WHERE 
    TRY_CAST(yearbuilt AS INT) > YEAR(GETDATE());

-- 6. Properties with invalid garage size
SELECT * 
FROM Properties 
WHERE 
    TRY_CAST(garagecarcnt AS INT) < 0 
    OR TRY_CAST(garagetotalsqft AS FLOAT) < 0;

-- 7. Properties with all major fields NULL or empty
SELECT * 
FROM Properties 
WHERE 
    (bedroomcnt IS NULL OR TRIM(bedroomcnt) = '')
    AND (bathroomcnt IS NULL OR TRIM(bathroomcnt) = '')
    AND (calculatedfinishedsquarefeet IS NULL OR TRIM(calculatedfinishedsquarefeet) = '')
    AND (structuretaxvaluedollarcnt IS NULL OR TRIM(structuretaxvaluedollarcnt) = '');

-- Sales with missing references
SELECT * 
FROM Sales s
LEFT JOIN Properties p ON s.PropertyID = p.parcelid
LEFT JOIN Clients c ON s.ClientID = c.ClientID
LEFT JOIN Agents a ON s.AgentID = a.AgentID
WHERE p.parcelid IS NULL OR c.ClientID IS NULL OR a.AgentID IS NULL;

-- Visits with missing references
SELECT * 
FROM Visits v
LEFT JOIN Properties p ON v.PropertyID = p.parcelid
LEFT JOIN Clients c ON v.ClientID = c.ClientID
LEFT JOIN Agents a ON v.AgentID = a.AgentID
WHERE p.parcelid IS NULL OR c.ClientID IS NULL OR a.AgentID IS NULL;

-- Duplicate visits by same client to same property on same day
SELECT PropertyID, ClientID, VisitDate, COUNT(*) 
FROM Visits 
GROUP BY PropertyID, ClientID, VisitDate 
HAVING COUNT(*) > 1;

-- Visits after sale
SELECT v.*
FROM Visits v
JOIN Sales s ON v.PropertyID = s.PropertyID
WHERE v.VisitDate > s.SaleDate;
------ put all null value in Properties_InvalidRecords
SELECT *
INTO Properties_InvalidRecords
FROM Properties 
WHERE 
    (bedroomcnt IS NULL OR TRIM(bedroomcnt) = '')
    AND (bathroomcnt IS NULL OR TRIM(bathroomcnt) = '')
    AND (calculatedfinishedsquarefeet IS NULL OR TRIM(calculatedfinishedsquarefeet) = '')
    AND (structuretaxvaluedollarcnt IS NULL OR TRIM(structuretaxvaluedollarcnt) = '');
--------- Delete all related id in Visits Table ------------------
DELETE FROM Visits
WHERE PropertyID IN (
    SELECT parcelid FROM Properties_InvalidRecords
);
--------- Delete all related id in Sales Table ------------------
DELETE FROM Sales
WHERE PropertyID IN (
    SELECT parcelid FROM Properties_InvalidRecords
);
-------  remove all null value --------------
DELETE FROM Properties 
WHERE parcelid IN (
    SELECT parcelid FROM Properties_InvalidRecords
);
