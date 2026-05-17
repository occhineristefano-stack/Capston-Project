-- CRAETING VIEWS

-- vw_ai_evolution_summary_2
CREATE OR REPLACE VIEW vw_ai_evolution_summary_2 AS
WITH cte_models AS (
    -- Aggreghiamo i modelli per anno e regione
    SELECT 
        YEAR(Publication_Date) AS Year, 
        Id_Region, 
        COUNT(Id_Model) AS Total_Models_Released
    FROM fact_ai_models
    GROUP BY YEAR(Publication_Date), Id_Region
),
cte_investments AS (
    -- Sommiamo gli investimenti 
    SELECT 
        Year, 
        Id_Region, 
        SUM(Private_Investment) AS Private_Investment_USD
    FROM fact_summary_investments
    GROUP BY Year, Id_Region
),
cte_publications AS (
    -- Prendiamo la quota di pubblicazioni
    SELECT 
        Year, 
        Id_Region, 
        MAX(Publications) AS AI_Pubs_Share_Percentage 
    FROM fact_ai_publications
    GROUP BY Year, Id_Region
),
base_timeline AS (
    -- Anno-Regione per non perdere record
    SELECT Year, Id_Region FROM cte_models
    UNION SELECT Year, Id_Region FROM cte_investments
    UNION SELECT Year, Id_Region FROM cte_publications
)
SELECT 
    t.Year,
    r.Region,
    COALESCE(m.Total_Models_Released, 0) AS Total_Models_Released,
    COALESCE(i.Private_Investment_USD, 0) AS Private_Investment_USD,
    COALESCE(p.AI_Pubs_Share_Percentage, 0.00) AS AI_Pubs_Share_Percentage
FROM base_timeline as t
JOIN dim_region as r ON t.Id_Region = r.Id_Region
LEFT JOIN cte_models as m ON t.Year = m.Year AND t.Id_Region = m.Id_Region
LEFT JOIN cte_investments as i ON t.Year = i.Year AND t.Id_Region = i.Id_Region
LEFT JOIN cte_publications as p ON t.Year = p.Year AND t.Id_Region = p.Id_Region;


-- vw_ability_exposure_detail
CREATE OR REPLACE VIEW vw_ability_exposure_detail AS
SELECT 
    ad.Ability_Domain,
    ee.O_NET_Abilities,
    ee.Ability_Level_AI_Exposure
FROM Fact_AI_Exposure_E as ee
JOIN Dim_Ability_Domain as ad ON ee.ID_Ability_Domain = ad.Id_Ability_Domain;


-- vw_job_impact_2030
CREATE OR REPLACE VIEW vw_job_impact_2030 AS
SELECT 
    r.Region,
    s.Sector,
    e.Education_Level,
    jt.Job_Title,
    jt.Job_Openings_2024,
    jt.Projected_Openings_2030,
    jt.Job_Growth,
    jt.Automation_Risk,
    jt.AI_Impact_Level,
    jt.Job_Status,
    -- Calcolo del tasso di crescita percentuale (si poteva fare su Power BI, ma lo faccio su SQL)
    CASE 
        WHEN jt.Job_Openings_2024 = 0 THEN 0
        ELSE ROUND(((jt.Projected_Openings_2030 - jt.Job_Openings_2024) / jt.Job_Openings_2024) * 100, 2)
    END AS Growth_Rate_Percentage
FROM Fact_Job_Trends as jt
JOIN Dim_Region as r ON jt.Id_Region = r.Id_Region
JOIN Dim_Sector as s ON jt.Id_Sector = s.Id_Sector
JOIN Dim_Education as e ON jt.Id_Education = e.Id_Education;


-- v_ascesa_tecnologica_2
CREATE OR REPLACE VIEW v_ascesa_tecnologica_2 AS
WITH cte_models_metrics AS (
    -- Calcoliamo le metriche tecniche dei modelli
    SELECT 
        YEAR(m.Publication_Date) AS Year, 
        m.Id_Region,
        ROUND(AVG(m.Compute_Log10_FLOP), 2) AS Media_Potenza_Calcolo_FLOPs,
        SUM(m.Parameters) AS Totale_Parametri_Modelli,
        GROUP_CONCAT(DISTINCT d.Domain SEPARATOR ', ') AS Domini_Sviluppati
    FROM fact_ai_models as m
    LEFT JOIN dim_domain as  d ON m.Id_Domain = d.Id_Domain
    GROUP BY YEAR(m.Publication_Date), m.Id_Region
)
SELECT 
    si.Year AS Anno,
    re.Region AS Regione,
    COALESCE(mm.Media_Potenza_Calcolo_FLOPs, 0) AS Media_Potenza_Calcolo_FLOPs,
    COALESCE(mm.Totale_Parametri_Modelli, 0) AS Totale_Parametri_Modelli,
    COALESCE(si.Private_Investment, 0) AS Investimento_Privato_USD,
    COALESCE(pu.Publications, 0) AS Percentuali_Pubblicazioni,
    mm.Domini_Sviluppati
FROM fact_summary_investments as si
JOIN dim_region as re ON si.Id_Region = re.Id_Region
LEFT JOIN cte_models_metrics as mm ON si.Year = mm.Year AND si.Id_Region = mm.Id_Region
LEFT JOIN fact_ai_publications as pu ON si.Year = pu.Year AND si.Id_Region = pu.Id_Region
ORDER BY Anno DESC, Investimento_Privato_USD DESC;


-- vw_macro_layoffs_trend
CREATE OR REPLACE VIEW vw_macro_layoffs_trend AS
SELECT 
    YEAR(f.Date) AS Anno,
    MONTH(f.Date) AS Mese,
    r.Region,
    s.Sector,
    COUNT(f.Id_Layoff) AS Numero_Eventi_Licenziamento,
    SUM(f.Total_Laid_Off) AS Totale_Persone_Licenziate
FROM Fact_Layoffs f
JOIN Dim_Region as r ON f.Id_Region = r.Id_Region
JOIN Dim_Sector as s ON f.Id_Sector = s.Id_Sector
GROUP BY 
    YEAR(f.Date), 
    MONTH(f.Date), 
    r.Region, 
    s.Sector;