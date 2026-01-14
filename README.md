<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:4F7CAC,100:1C2B36&height=180&section=header&text=NF%20Risk%20Stratification&fontSize=38&fontColor=E6EEF3&animation=fadeIn&fontAlignY=45" />
</p>


<p align="center">
  🔬 Clinical Risk Stratification in Necrotizing Fasciitis &nbsp;|&nbsp; 🧠 NPC & Bootstrap Statistics &nbsp;|&nbsp; 📊 Reproducible Research
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Language-R-blue?style=flat-square"/>
  <img src="https://img.shields.io/badge/Statistics-NPC%20%26%20Bootstrap-brightgreen?style=flat-square"/>
  <img src="https://img.shields.io/badge/Clinical-Decision%20Support-orange?style=flat-square"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square"/>
  <img src="https://img.shields.io/badge/Status-Active-brightgreen?style=flat-square"/>
</p>

# 📈 NF Risk Stratification using NPC & Bootstrap

This repository provides a **reproducible statistical framework** for evaluating clinical risk in **Necrotizing Fasciitis (NF)** using **Nonparametric Combination (NPC) tests** and **bootstrap resampling**.

The pipeline is designed to work with **small, heterogeneous clinical datasets**, where classical parametric models fail, and is fully aligned with the peer-reviewed methodology described in:

> **Permutation-Based Analysis of Clinical Variables in Necrotizing Fasciitis Using NPC and Bootstrap**  
> Piscopo, G., Bandaru, S. T., Giacalone, M., & Longobardi, M. (2025).  
> *Mathematics*, **13**(17), 2869.  
> https://doi.org/10.3390/math13172869

---

## 🧬 Clinical Variables Analyzed

This project focuses on clinically meaningful predictors and outcomes:

| Variable | Clinical Meaning |
|--------|-----------------|
| **HBA1C** | Glycemic control (diabetes severity) |
| **ALBUMINA** | Nutritional status |
| **MORTO** | Mortality outcome |
| **AMPUTAZIONE** | Major amputation outcome |

These variables are combined through NPC testing to identify **global patient risk profiles**.

---

## 🔬 What the System Computes

The scripts allow full replication of:

- Partial and global **hypothesis testing**
- **Fisher, Tippett, and Lipták** combination methods
- **Bonferroni correction** for multiple testing
- **Bootstrap confidence intervals** for clinical variables
- **Patient severity ranking** using NPC
- **Clinical visualizations**:
  - Boxplots  
  - Violin plots  
  - Heatmaps  

This enables **data-driven stratification of NF patients** into risk profiles.

---

## 📁 Repository Structure

```
code/
 ├── npc_analysis.R         → Partial tests, Fisher/Tippett/Lipták combinations, Bonferroni correction
 ├── bootstrap_analysis.R  → Bootstrap resampling for HBA1C and ALBUMINA
 ├── ranking_analysis.R    → Global patient severity ranking via NPC
 ├── descriptive_stats.R  → Descriptive statistics and plots
 └── utils.R               → Helper functions for reproducibility

data/
 └── nf_clinical_data.csv  → Place your dataset here (not provided due to privacy)
```

---

## ⚠️ Data Privacy

The real clinical dataset is **not included** due to ethical and privacy restrictions.  
You must place your own anonymized dataset here:

```
data/nf_clinical_data.csv
```

---

## ▶ How to Run

### 1. Clone the repository
```bash
git clone https://github.com/saitejabandaru-in/nf-risk-stratification.git
cd nf-risk-stratification
```

### 2. Add the dataset
Place your CSV file into:
```
data/nf_clinical_data.csv
```

### 3. Run the full analytical pipeline
```r
source("code/descriptive_stats.R")
source("code/npc_analysis.R")
source("code/bootstrap_analysis.R")
source("code/ranking_analysis.R")
```

---

## 📤 Outputs

The pipeline produces:

- Partial and global **p-values**
- **Bonferroni-adjusted** hypothesis tests
- **Bootstrap confidence intervals**
- **Patient risk rankings**
- Visualizations:
  - Boxplots  
  - Violin plots  
  - Heatmaps  

These outputs support **clinical decision-making and risk stratification**.

---

## 🧠 What This Project Shows

This repository demonstrates:

✔ Advanced statistical modeling  
✔ Nonparametric hypothesis testing  
✔ Bootstrap inference  
✔ Clinical data analytics  
✔ Reproducible research pipelines  
✔ Research-grade software engineering  

It is suitable for:
- Clinical data scientists  
- Biostatistics teams  
- Medical AI research  
- Graduate-level analytics portfolios  

---

## 👨‍💻 Author

**Sai Teja Bandaru**  
Data Scientist & Clinical Analytics Researcher  
Università degli Studi della Campania Luigi Vanvitelli  

---

## ⭐ If You Find This Useful

Please ⭐ the repository — it helps others discover reproducible clinical analytics!
