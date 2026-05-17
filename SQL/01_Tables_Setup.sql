-- DB 
CREATE DATABASE IF NOT EXISTS Ai_Global_Trends;
USE Ai_Global_Trends;

-- DIMENSION TABLES

-- 1 Dim_Region
CREATE TABLE IF NOT EXISTS Dim_Region(
Id_Region int not null auto_increment Primary Key,
Region varchar(45) not null
);

-- 2 Dim_Sector
CREATE TABLE IF NOT EXISTS Dim_Sector(
Id_Sector int not null auto_increment Primary Key,
Sector varchar(45) not null
);

-- 3 Dim_Occupational Field
CREATE TABLE IF NOT EXISTS Dim_Occupational_Field(
Id_Occupational_Field int not null auto_increment Primary Key,
Occupational_Field varchar(100) not null
);

-- 4 Dim_Macro_Category
CREATE TABLE IF NOT EXISTS Dim_Ability_Domain(
Id_Ability_Domain int not null auto_increment Primary Key,
Ability_Domain varchar(55) not null
);

-- 5 Dim_Domain
CREATE TABLE IF NOT EXISTS Dim_Domain(
Id_Domain int not null auto_increment Primary Key,
Domain varchar(255) not null
);

-- 6 Dim_Education
CREATE TABLE IF NOT EXISTS Dim_Education(
Id_Education int not null auto_increment Primary Key,
Education_Level varchar(100) not null
);

-- 7 Dim_Calendar
CREATE TABLE IF NOT EXISTS Dim_Calendar(
Data_Completa date not null Primary Key,
Anno int not null,
Mese int not null,
Trimestre int not null,
Nome_Mese varchar(20) not null
)


-- FACT TABLES

-- 1 Fact_Layoffs
CREATE TABLE IF NOT EXISTS Fact_Layoffs(
Id_Layoff int auto_increment not null Primary Key,
Company varchar(255) not null,
Total_Laid_Off int not null,
Date date not null,
Percentage_Laid_Off decimal(5,2),
Id_Sector int not null,
Id_Region int not null,
CONSTRAINT FK_Layoffs_Sector FOREIGN KEY (Id_Sector) REFERENCES Dim_Sector(Id_Sector),
CONSTRAINT FK_Layoffs_Region FOREIGN KEY (Id_Region) REFERENCES Dim_Region(Id_Region)
);

-- 2 Fact_AI_Models
CREATE TABLE IF NOT EXISTS Fact_AI_Models(
Id_Model int not null auto_increment Primary Key,
Publication_Date date not null,
Compute_Log10_FLOP decimal(10,2),
Parameters bigint,
Organization varchar(100),
Id_Domain int not null,
Id_Region int not null,
CONSTRAINT FK_AIMod_Domain FOREIGN KEY (Id_Domain) REFERENCES Dim_Domain(Id_Domain),
CONSTRAINT FK_AIMod_Region FOREIGN KEY (Id_Region) REFERENCES Dim_Region(Id_Region)
);

-- 3 Fact_Tech_Market_CAP
CREATE TABLE IF NOT EXISTS Fact_Tech_Market_CAP(
id_Company int not null auto_increment Primary Key,
Company_Name varchar(100),
Market_Cap_USD_Bilions float,
Id_Sector int not null,
CONSTRAINT FK_Tech_Sector FOREIGN KEY (Id_Sector) REFERENCES Dim_Sector(Id_Sector)
);

-- 4 Fact_Summary_Investments
CREATE TABLE IF NOT EXISTS Fact_Summary_Investments(
Id_Investment int not null auto_increment Primary Key,
Id_Region int not null,
Year year,
Private_Investment bigint,
CONSTRAINT FK_Investment_Region FOREIGN KEY (Id_Region) REFERENCES Dim_Region(Id_Region)
);

-- 5 Fact_Job_Occupation
CREATE TABLE IF NOT EXISTS Fact_Job_Occupation(
Id_Job_Occupation int not null auto_increment Primary Key,
Id_Region int not null,
Year year,
Percentage_of_Occupation decimal(5,2),
CONSTRAINT FK_JobOcc_Region FOREIGN KEY (Id_Region) REFERENCES Dim_Region(Id_Region)
);

-- 6 Fact_AI_Exposure_A
CREATE TABLE IF NOT EXISTS Fact_AI_Exposure_A(
Id_Exposure_A int not null auto_increment Primary Key,
SOC_Code varchar(20) not null,
AIOE decimal (5,3),
ID_Occupational_Field int not null,
CONSTRAINT FK_ExpA_Occupation_Field FOREIGN KEY (ID_Occupational_Field) REFERENCES Dim_Occupational_Field(Id_Occupational_Field)
);

-- 7 Fact_AI_Exposure_B
CREATE TABLE IF NOT EXISTS Fact_AI_Exposure_B(
ID_Exposure_B int not null auto_increment Primary Key,
NAICS int not null,
Industry_Title varchar(255),
AIIE decimal(5,3) not null,
ID_Sector int not null,
CONSTRAINT FK_ExpB_Sector FOREIGN KEY (Id_Sector) REFERENCES Dim_Sector(Id_Sector)
);


-- 8 Fact_AI_Exposure_E
CREATE TABLE IF NOT EXISTS Fact_AI_Exposure_E(
ID_Exposure_E int not null auto_increment Primary Key,
O_NET_Abilities varchar(100) not null,
Ability_Level_AI_Exposure decimal(5,3) not null,
ID_Ability_Domain int not null,
CONSTRAINT FK_ExpE_Ability_Domain FOREIGN KEY(ID_Ability_Domain) REFERENCES dim_ability_domain(id_ability_domain)
);

-- 9 Fact_AI_Publications
CREATE TABLE IF NOT EXISTS Fact_AI_Publications(
Id_Publication int not null auto_increment Primary Key,
Id_Region int not null,
Publications decimal(10,2),
Year year,
CONSTRAINT FK_Pub_Region FOREIGN KEY (Id_Region) REFERENCES Dim_Region(Id_Region)
);

-- 10 Fact_Job_Trends
CREATE TABLE IF NOT EXISTS Fact_Job_Trends (
Id_Job_Trend int not null auto_increment Primary Key,
Id_Region int not null,
Job_Title varchar(100),
Job_Openings_2024 int not null,
Projected_Openings_2030 int not null,
Automation_Risk decimal(5,2),
AI_Impact_Level varchar(45),
Job_Status varchar(45),
Job_Growth int not null,
Id_Sector int not null,
Id_Education int not null,
CONSTRAINT FK_Trends_Sector FOREIGN KEY (Id_Sector) REFERENCES Dim_Sector(Id_Sector),
CONSTRAINT FK_Trends_Region FOREIGN KEY (Id_Region) REFERENCES Dim_Region(Id_Region),
CONSTRAINT FK_Trends_Education FOREIGN KEY (Id_Education) REFERENCES Dim_Education(Id_Education)
);



-- CREATING STAGING TABLES

-- 1 STAGING Fact_Layoffs
CREATE TABLE Staging_Fact_Layoffs(
Company varchar(255) not null,
Total_Laid_Off int not null,
Date date not null,
Percentage_Laid_Off decimal(5,2),
Sector_Name varchar(45), 
Region_Name varchar(45) 
);

-- 2 STAGING Fact_AI_Models
CREATE TABLE IF NOT EXISTS Staging_Fact_AI_Models(
Publication_Date date not null,
Compute_Log10_FLOP decimal(10,2),
Parameters bigint,
Domain varchar(100),
Region varchar(45),
Organization varchar(100)
);

-- 3 STAGING Fact_Tech_Market_CAP
CREATE TABLE IF NOT EXISTS Staging_Fact_Tech_Market_CAP(
Company_Name varchar(100),
Market_Cap_USD_Bilions float,
Sector varchar(100)
);

-- 4 STAGING Fact_Summary_Investments
CREATE TABLE IF NOT EXISTS Staging_Fact_Summary_Investments(
Region varchar(45),
Year year,
Private_Investment bigint
);

-- 5 STAGING Fact_Job_Occupation
CREATE TABLE IF NOT EXISTS Staging_Fact_Job_Occupation(
Region varchar(45),
Year year,
Percentage_of_Occupation decimal(5,2)
);

-- 6 STAGING Fact_AI_Exposure_A
CREATE TABLE IF NOT EXISTS Staging_Fact_AI_Exposure_A(
SOC_Code varchar(20) not null,
Occupation_Title varchar(255),
AIOE decimal (5,3),
Broad_Category varchar(100)
);

-- 7 STAGING Fact_AI_Exposure_B
CREATE TABLE IF NOT EXISTS Staging_Fact_AI_Exposure_B(
NAICS int not null, 
Industry_Title varchar(255),
AIIE decimal(5,3) not null,
Sector varchar(100)
);

-- 8 STAGING Fact_AI_Exposure_E
CREATE TABLE IF NOT EXISTS Staging_Fact_AI_Exposure_E(
O_NET_Abilities varchar(100) not null Primary Key,
Ability_Level_AI_Exposure decimal(5,3) not null,
Ability_Domain varchar(45)
);

-- 9 STAGING Fact_AI_Publications
CREATE TABLE IF NOT EXISTS Staging_Fact_AI_Publications(
Region varchar(45),
Publications decimal(10,2),
Year year
);

-- 10 STAGING Fact_Job_Trends
CREATE TABLE IF NOT EXISTS Staging_Fact_Job_Trends (
Region varchar(45),
Job_Title varchar(100),
Job_Openings_2024 int not null,
Projected_Openings_2030 int not null,
Automation_Risk decimal(5,2),
AI_Impact_Level varchar(45),
Job_Status varchar(45),
Job_Growth int not null,
Required_Education varchar(100),
Sector varchar(100)
);