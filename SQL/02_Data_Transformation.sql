-- INSERT DIMENSION TABLES

-- Dim_Region
INSERT INTO dim_region(Region)
VALUES('China'),
	('United States'),
    ('Europe');
    
-- Dim_Sector
INSERT INTO dim_sector(Sector)
VALUES ('Business Service'), ('Cloud & Ecosystems'),
	('Consumer & Retail'), ('Data & Storage'),
    ('Infrastructure (Chip)'), ('Infrastructure (General)'),
    ('Software & Platform');

-- Dim_Occupational_Field
INSERT INTO dim_occupational_field(Occupational_Field)
VALUES ('Business & Legal'), ('Education & Core'),
	('Operations & Services'), ('STEM & Analysis');

-- Dim_Ability_Domain
INSERT INTO dim_ability_domain(ability_domain)
VALUES ('Cognitive'), ('Physical'), ('Sensory');

-- Dim_Domain
INSERT INTO dim_domain(domain)
VALUES ('Language & Audio'), ('Vision & Media'),
	('Multimodal'), ('Science & Engineering'),
	('Robotics & Games'), ('Other');
    
-- Dim_Education    
INSERT INTO dim_education(education_level)
VALUES ('PhD'), ('Associate Degree'), ('Bachelor''s Degree'),
	('High School'), ('Master''s Degree');
    
-- Dim Calendar
-- Prendendo tutti i miei dati date
SET SESSION cte_max_recursion_depth = 50000;    
INSERT INTO dim_calendar (Data_Completa, Anno, Mese, Trimestre, Nome_Mese)
WITH RECURSIVE days AS (
    
    SELECT '1947-01-01' AS d
    UNION ALL
   
    SELECT d + INTERVAL 1 DAY
    FROM days
    WHERE d < '2026-12-31'
)
SELECT 
    d AS Data_Completa,
    YEAR(d) AS Anno,
    MONTH(d) AS Mese,
    QUARTER(d) AS Trimestre,
    CASE MONTH(d)
        WHEN 1 THEN 'Gennaio'
        WHEN 2 THEN 'Febbraio'
        WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Aprile'
        WHEN 5 THEN 'Maggio'
        WHEN 6 THEN 'Giugno'
        WHEN 7 THEN 'Luglio'
        WHEN 8 THEN 'Agosto'
        WHEN 9 THEN 'Settembre'
        WHEN 10 THEN 'Ottobre'
        WHEN 11 THEN 'Novembre'
        WHEN 12 THEN 'Dicembre'
    END AS Nome_Mese
FROM days;


-- The data in the staging tables 
-- was imported using the ‘Table Data Import Wizard’ 
-- from the CSV files in the Dataset folder!


-- CONVERTING STAGING TABLES TO FACT TABLES

-- Fact_Layoffs
INSERT INTO Fact_Layoffs (Company, Total_Laid_Off, Date, Percentage_Laid_Off, Id_Sector, Id_Region)
SELECT 
    s.Company, 
    s.Total_Laid_Off, 
    s.Date, 
    s.Percentage_Laid_Off, 
    sec.Id_Sector,
    reg.Id_Region  
FROM Staging_fact_Layoffs as s
JOIN Dim_Sector as sec ON s.Sector_Name = sec.Sector
JOIN Dim_Region as reg ON s.Region_Name = reg.Region;

-- Fact_AI_Models
INSERT INTO Fact_AI_Models (Publication_Date, Compute_Log10_FLOP, Parameters, Organization, Id_Domain, Id_Region)
SELECT 
	s.Publication_Date, 
	s.Compute_Log10_FLOP, 
    s.Parameters, 
    s.Organization, 
    dom.Id_Domain, 
    reg.Id_Region
FROM Staging_Fact_AI_Models as s
JOIN Dim_Domain as dom ON s.Domain = dom.Domain
JOIN Dim_Region as reg ON s.Region = reg.Region;

-- Fact_Tech_Market_CAP
INSERT INTO Fact_Tech_Market_CAP (Company_Name, Market_Cap_USD_Bilions, Id_Sector)
SELECT 
	s.Company_Name, 
    s.Market_Cap_USD_Bilions, 
    sec.Id_Sector
FROM Staging_Fact_Tech_Market_CAP as s
JOIN Dim_Sector as sec ON s.Sector = sec.Sector;

-- Fact_Summary_Investments
INSERT INTO Fact_Summary_Investments (Id_Region, Year, Private_Investment)
SELECT 
	reg.Id_Region, 
    s.Year, 
    s.Private_Investment
FROM Staging_Fact_Summary_Investments as s
JOIN Dim_Region as reg ON s.Region = reg.Region;

-- Fact_Job_Occupation
INSERT INTO Fact_Job_Occupation (Id_Region, Year, Percentage_of_Occupation)
SELECT 
	reg.Id_Region, 
	s.Year, 
	s.Percentage_of_Occupation
FROM Staging_Fact_Job_Occupation as s
JOIN Dim_Region as reg ON s.Region = reg.Region;

-- Fact_AI_Exposure_A
INSERT INTO Fact_AI_Exposure_A (SOC_Code, AIOE, Id_Occupational_Field)
SELECT 
	s.SOC_Code, 
    s.AIOE, 
    occ.Id_Occupational_Field
FROM Staging_Fact_AI_Exposure_A as s
JOIN Dim_Occupational_Field as occ ON s.Broad_Category = occ.Occupational_Field;

-- Fact_AI_Exposure_B
INSERT INTO Fact_AI_Exposure_B (NAICS, Industry_Title, AIIE, Id_Sector)
SELECT 
	s.NAICS, 
    s.Industry_Title, 
    s.AIIE, 
    sec.Id_Sector
FROM Staging_Fact_AI_Exposure_B as s
JOIN Dim_Sector as sec ON s.Sector = sec.Sector;

-- Fact_AI_Exposure_E
INSERT INTO Fact_AI_Exposure_E (O_NET_Abilities, Ability_Level_AI_Exposure, Id_Ability_Domain)
SELECT 
	s.O_NET_Abilities, 
    s.Ability_Level_AI_Exposure, 
    ab.Id_Ability_Domain
FROM Staging_Fact_AI_Exposure_E as s
JOIN Dim_Ability_Domain as ab ON s.Ability_Domain = ab.Ability_Domain;

-- Fact_AI_Publications
INSERT INTO Fact_AI_Publications (Id_Region, Publications, Year)
SELECT 
	reg.Id_Region, 
    s.Publications, 
    s.Year
FROM Staging_Fact_AI_Publications as s
JOIN Dim_Region as reg ON s.Region = reg.Region;

-- Fact_Job_Trends
INSERT INTO Fact_Job_Trends (Id_Region, Job_Title, Job_Openings_2024, Projected_Openings_2030, Automation_Risk, AI_Impact_Level, Job_Status, Job_Growth, Id_Sector, Id_Education)
SELECT 
	reg.Id_Region, 
    s.Job_Title, 
    s.Job_Openings_2024, 
    s.Projected_Openings_2030, 
    s.Automation_Risk, 
    s.AI_Impact_Level, 
    s.Job_Status, 
    s.Job_Growth, 
    sec.Id_Sector, 
    edu.Id_Education
FROM Staging_Fact_Job_Trends as s
JOIN Dim_Region as reg ON s.Region = reg.Region
JOIN Dim_Sector as sec ON s.Sector = sec.Sector
JOIN Dim_Education as edu ON s.Required_Education = edu.Education_Level;

-- 