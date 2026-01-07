# NPC and Bootstrap Analysis for Necrotizing Fasciitis

This repository contains R scripts accompanying the article:

**Piscopo, G., Bandaru, S.T., Giacalone, M., & Longobardi, M. (2025).  
Permutation-Based Analysis of Clinical Variables in Necrotizing Fasciitis Using NPC and Bootstrap.  
Mathematics, 13(x), https://doi.org/10.3390/xxxxx**

---

## Overview
Necrotizing fasciitis (NF) is a rare but severe soft tissue infection.  
This project applies **Nonparametric Combination (NPC) tests** and **bootstrap resampling** to evaluate clinical biomarkers:

- **HBA1C** (glycemic control)
- **ALBUMINA** (nutritional status)
- **MORTO** (mortality outcome)
- **AMPUTAZIONE** (major amputation outcome)

The scripts allow replication of:
- Partial and global hypothesis testing  
- Bootstrap confidence interval estimation  
- Patient severity ranking via NPC  
- Visualizations (boxplots, violin plots, heatmaps)

---

## Repository Contents
- `code/npc_analysis.R` → Partial tests, Fisher/Tippett/Lipták combinations, Bonferroni correction  
- `code/bootstrap_analysis.R` → Bootstrap resampling for HBA1C and ALBUMINA  
- `code/ranking_analysis.R` → Global severity ranking computation  
- `code/descriptive_stats.R` → Basic descriptive statistics  
- `code/utils.R` → Helper functions for reproducibility  

- `data/` → Place your dataset here (`nf_clinical_data.csv`). **(Not provided due to privacy restrictions)**  

---

## Requirements
- R (≥ 4.3.1)
- R packages:
  ```r
  install.packages(c("boot", "dplyr", "tidyverse", "pheatmap"))
  ```

---

## Usage
1. Clone the repository:
   ```bash
   git clone https://github.com/<your-username>/nf-risk-stratification.git
   cd nf-risk-stratification
   ```

2. Add the clinical dataset into the `data/` folder:
   ```
   data/nf_clinical_data.csv
   ```

3. Run the scripts in order:
   ```r
   source("code/descriptive_stats.R")
   source("code/npc_analysis.R")
   source("code/bootstrap_analysis.R")
   source("code/ranking_analysis.R")
   ```

4. Outputs include:
   - Partial and global p-values  
   - Bonferroni-adjusted results  
   - Bootstrap confidence intervals  
   - Ranked patient severity scores  
   - Visualizations (boxplots, violin plots, heatmaps)  

---

## Citation
If you use this repository, please cite the article:

> Piscopo, G., Bandaru, S.T., Giacalone, M., & Longobardi, M. (2025).  
> *Permutation-Based Analysis of Clinical Variables in Necrotizing Fasciitis Using NPC and Bootstrap*.  
> Mathematics, 13(x), https://www.mdpi.com/2227-7390/13/17/2869
---

## Note
- The **real dataset is not included** due to ethical and privacy restrictions.  
- An empty `data/` folder is provided; please insert the anonymized dataset to reproduce results.  
- All analysis code was validated in **R version 4.3.1**.  

