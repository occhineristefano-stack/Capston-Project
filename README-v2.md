# Human vs AI: Market Analytics & Labor Impact

Benvenuto nel progetto **Human vs AI**, un'analisi dati end-to-end progettata per esplorare l'impatto globale dello sviluppo dell'Intelligenza Artificiale sul mercato del lavoro, le tendenze di investimento e l'evoluzione tecnologica. Il progetto confronta le dinamiche di tre macro-regioni principali: **Stati Uniti, Cina ed Europa**.

## Panoramica del Progetto
Questa repository documenta l'intero ciclo di vita del dato (dall'estrazione alla visualizzazione finale), dimostrando un solido processo di data engineering e data analysis. L'obiettivo principale è quantificare la "corsa all'AGI" (tramite potenza di calcolo e parametri dei modelli) e correlarla all'impatto socio-economico, evidenziando le professioni a rischio automazione e le proiezioni di crescita occupazionale fino al 2030.

## Struttura della Repository

La repository è organizzata nelle seguenti directory:

- **`Dataset/`** - **`Raw/`**: Contiene i dataset originali e grezzi (investimenti, parametri tecnici AI, dati occupazionali).
  - **`Cleaned/`**: Contiene i dataset puliti e pronti per l'importazione nel database.
- **`Notebook/`**
  - Contiene il notebook Jupyter (`AI_Labor_Market_Analysis.ipynb`) con tutti gli script Python utilizzati per l'ETL (Extract, Transform, Load).
- **`SQL/`**
  - Contiene tutti gli script per la creazione e gestione del database MySQL:
    - `01_Tables_Setup.sql`: Creazione dello schema, delle tabelle dimensionali e di staging.
    - `02_Data_Transformation.sql`: Logiche di inserimento e popolamento delle tabelle dei fatti.
    - `03_Views_Definition.sql`: Viste SQL pre-calcolate e ottimizzate per l'ingestione in Power BI.
    - `04_Full_Database_Dump.sql`: Dump completo per la riproducibilità del database locale.
- **`Power BI/`**
  - `Human_vs_AI_Market_Analytics.pbix`: Il file del report interattivo di Power BI.
  - `Human_vs_AI_Market_Analytics.pdf`: Esportazione statica della dashboard.

## Fasi del Progetto (Workflow)

### 1. Data Sourcing & ETL (Python)
I dati originali presentavano inconsistenze strutturali e formati misti. Utilizzando **Python (Pandas, NumPy)**, i dataset sono stati puliti e armonizzati. 
*Nota tecnica:* Durante questa fase è stata implementata una logica di data cleaning e di mapping custom per raggruppare nazioni specifiche all'interno della macro-regione "Europa", sovrascrivendo i raggruppamenti automatici standard per garantire un confronto perfettamente bilanciato con Stati Uniti e Cina.

### 2. Data Modeling & Data Warehousing (MySQL)
I dati puliti sono stati caricati in un database relazionale (MySQL). 
È stato progettato un modello dati a **Star Schema** ottimizzato per l'analisi OLAP, separando le entità in tabelle dimensionali (es. `Dim_Region`, `Dim_Sector`, `Dim_Calendar`) e tabelle dei fatti (es. `Fact_AI_Models`, `Fact_Summary_Investments`, `Fact_Layoffs`). Sono state inoltre create delle Viste SQL (`Views`) per pre-aggregare metriche complesse e alleggerire il carico computazionale della BI.

### 3. Data Visualization (Power BI)
I dati sono stati infine modellati in Power BI, creando misure DAX personalizzate per lo sviluppo di una dashboard esplorativa divisa in macro-tematiche:
- **Investment Landscape:** Distribuzione dei fondi privati globali e capitalizzazione di mercato delle aziende "Big Tech" (es. NVIDIA, Microsoft).
- **The Race for AGI:** Analisi temporale esponenziale di *Compute* (FLOPs) e *Parameters* dal 2012 in poi, confrontando USA, Cina ed Europa.
- **Workforce 2030 (The Human-AI Nexus):** Correlazione tra il tasso di vulnerabilità settoriale (Automation Risk Index) e la creazione o perdita di posti di lavoro prevista entro il 2030.

## Stack Tecnologico
- **Linguaggi:** Python, SQL, DAX
- **Librerie:** Pandas, NumPy, OS
- **Database:** MySQL
- **Data Visualization & BI:** Microsoft Power BI
