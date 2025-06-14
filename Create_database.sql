Create database Real_Estate;
use Real_Estate;
-------------Create Properties Table ---------------
CREATE TABLE Properties(
parcelid INT NOT NULL,
airconditioningtypeid varchar(50),
architecturalstyletypeid varchar(50),
basementsqft varchar(50),
bathroomcnt varchar(50),
bedroomcnt varchar(50),
buildingclasstypeid varchar(50),
buildingqualitytypeid varchar(50),
calculatedbathnbr varchar(50),
decktypeid varchar(50),
finishedfloor1squarefeet varchar(50),
calculatedfinishedsquarefeet varchar(50),
finishedsquarefeet12 varchar(50),
finishedsquarefeet13 varchar(50),
finishedsquarefeet15 varchar(50),
finishedsquarefeet50 varchar(50),
finishedsquarefeet6 varchar(50),
fips varchar(50),
fireplacecnt varchar(50),
fullbathcnt varchar(50),
garagecarcnt varchar(50),
garagetotalsqft varchar(50),
hashottuborspa varchar(50),
heatingorsystemtypeid varchar(50),
latitude varchar(50),
longitude varchar(50),
lotsizesquarefeet varchar(50),
poolcnt varchar(50),
poolsizesum varchar(50),
pooltypeid10 varchar(50),
pooltypeid2 varchar(50),
pooltypeid7 varchar(50),
propertycountylandusecode varchar(50),
propertylandusetypeid varchar(50),
propertyzoningdesc varchar(50),
rawcensustractandblock varchar(50),
regionidcity varchar(50),
regionidcounty varchar(50),
regionidneighborhood varchar(50),
regionidzip varchar(50),
roomcnt varchar(50),
storytypeid varchar(50),
threequarterbathnbr varchar(50),
typeconstructiontypeid varchar(50),
unitcnt  varchar(50),
yardbuildingsqft17 varchar(50),
yardbuildingsqft26 varchar(50),
yearbuilt varchar(50),
numberofstories varchar(50),
fireplaceflag varchar(50),
structuretaxvaluedollarcnt varchar(50),
taxvaluedollarcnt varchar(50),
assessmentyear varchar(50),
landtaxvaluedollarcnt varchar(50),
taxamount varchar(50),
taxdelinquencyflag varchar(50),
taxdelinquencyyear varchar(50),
censustractandblock varchar(50)
PRIMARY KEY(parcelid)
);

-------------Create Clients Table ---------------
CREATE TABLE Clients(
ClientID INT NOT NULL,
FirstName VARCHAR(50),
LastName VARCHAR(50),
Phone VARCHAR(100),
Email VARCHAR(100)
PRIMARY KEY(ClientID)
);

-------------Create Visits Table ---------------
CREATE TABLE Agents(
AgentID INT NOT NULL,
FirstName VARCHAR(50),
LastName VARCHAR(50),
Phone VARCHAR(100),
Email VARCHAR(100)
PRIMARY KEY(AgentID)
);

-------------Create Visits Table ---------------
CREATE TABLE Visits(
VisitID INT NOT NULL,
PropertyID int not null ,
ClientID int not null ,
AgentID int not null , 
VisitDate DATE
PRIMARY KEY(VisitID)
CONSTRAINT FK_Visits_Properties FOREIGN KEY(PropertyID)
REFERENCES Properties(parcelid),
CONSTRAINT FK_Visits_Clints FOREIGN KEY(ClientID) 
REFERENCES Clients(ClientID),
CONSTRAINT FK_Visits_Agents FOREIGN KEY(AgentID) 
REFERENCES Agents(AgentID)
);

-------------Create Sales Table ---------------
create table Sales (
SaleID int not null ,
PropertyID int not null ,
ClientID int not null ,
AgentID int not null , 
SaleDate DATE,
SalePrice decimal(20,4)
PRIMARY KEY(SaleID)
CONSTRAINT FK_Sales_Properties FOREIGN KEY(PropertyID)
REFERENCES Properties(parcelid),
CONSTRAINT FK_Sales_Clints FOREIGN KEY(ClientID) 
REFERENCES Clients(ClientID),
CONSTRAINT FK_Sales_Agents FOREIGN KEY(AgentID) 
REFERENCES Agents(AgentID)
);

-- insert data into Agents Table
BULK INSERT Agents
FROM 'E:\Projects_dataanalysis\Project_bootcamp\File_CSV\Agents.csv'  -- change path to match path file in your pc 
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    TABLOCK
)
-- insert data into Clients Table
BULK INSERT Clients
FROM 'E:\Projects_dataanalysis\Project_bootcamp\File_CSV\Clients.csv'  -- change path to match path file in your pc 
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    TABLOCK
)
-- insert data into Properties Table
BULK INSERT Properties
FROM 'E:\Projects_dataanalysis\Project_bootcamp\File_CSV\Properties.csv'  -- change path to match path file in your pc 
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    TABLOCK
)
-- insert data into Sales Table
BULK INSERT Sales
FROM 'E:\Projects_dataanalysis\Project_bootcamp\File_CSV\Sales.csv'  -- change path to match path file in your pc 
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    TABLOCK
)
-- insert data into Visits Table
BULK INSERT Visits
FROM 'E:\Projects_dataanalysis\Project_bootcamp\File_CSV\Visits.csv'  -- change path to match path file in your pc 
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',  
    ROWTERMINATOR = '\n',   
    TABLOCK
)



------ use dictionary to replae each value in propertylandusetypeid to value in dicrionary--------
ALTER TABLE Properties
ADD  PropertyType VARCHAR(50);
UPDATE Properties
SET PropertyType=
CASE
when propertylandusetypeid='31.0' then 'Commercial/Office/Residential Mixed Used'
when propertylandusetypeid='46.0' then 'Multi-Story Store'
when propertylandusetypeid='47.0' then 'Store/Office (Mixed Use)'
when propertylandusetypeid='246.0' then 'Duplex (2 Units, Any Combination)'
when propertylandusetypeid='247.0' then 'Triplex (3 Units, Any Combination)'
when propertylandusetypeid='248.0' then 'Quadruplex (4 Units, Any Combination)'
when propertylandusetypeid='260.0' then 'Residential General'
when propertylandusetypeid='261.0' then 'Single Family Residential'
when propertylandusetypeid='262.0' then 'Rural Residence'
when propertylandusetypeid='263.0' then 'Mobile Home'
when propertylandusetypeid='264.0' then 'Townhouse'
when propertylandusetypeid='265.0' then 'Cluster Home'
when propertylandusetypeid='266.0' then 'Condominium'
when propertylandusetypeid='267.0' then 'Cooperative'
when propertylandusetypeid='268.0' then 'Row House'
when propertylandusetypeid='269.0' then 'Planned Unit Development'
when propertylandusetypeid='270.0' then 'Residential Common Area'
when propertylandusetypeid='271.0' then 'Timeshare'
when propertylandusetypeid='273.0' then 'Bungalow	'
when propertylandusetypeid='274.0' then 'Zero Lot Line'
when propertylandusetypeid='275.0' then 'Manufactured, Modular, Prefabricated Homes'
when propertylandusetypeid='276.0' then 'Patio Home'
when propertylandusetypeid='279.0' then 'Inferred Single Family Residential	'
when propertylandusetypeid='290.0' then 'Vacant Land - General'
when propertylandusetypeid='291.0' then 'Residential Vacant Land'
ELSE ' '  
END;

-------------------- make location column -----------------
ALTER TABLE Properties
ADD latitude_corrected FLOAT, 
    longitude_corrected FLOAT;

UPDATE Properties
SET 
    latitude_corrected = TRY_CAST(latitude AS FLOAT) / 1000000.0,
    longitude_corrected = TRY_CAST(longitude AS FLOAT) / 1000000.0;
ALTER TABLE Properties ADD location VARCHAR(100);




