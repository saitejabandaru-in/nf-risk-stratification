<p align="center">
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:4F7CAC,100:1C2B36&height=180&section=header&text=NF%20Risk%20Stratification&fontSize=38&fontColor=E6EEF3&animation=fadeIn&fontAlignY=45" />
</p>

<p align="center">
  Clinical risk stratification in necrotizing fasciitis | NPC statistics | Bootstrap inference | R package
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Language-R-blue?style=flat-square"/>
  <img src="https://img.shields.io/badge/Package-nfRiskStratification-brightgreen?style=flat-square"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square"/>
  <img src="https://img.shields.io/badge/Status-Release%200.1.0-brightgreen?style=flat-square"/>
</p>

# NF Risk Stratification

`nfRiskStratification` is an installable R package for reproducible clinical
risk stratification in necrotizing fasciitis. It supports descriptive clinical
summaries, partial tests, Fisher/Tippett/Liptak nonparametric combination
methods, bootstrap confidence intervals, and patient severity ranking.

The package is aligned with the methodology described in:

> Permutation-Based Analysis of Clinical Variables in Necrotizing Fasciitis
> Using NPC and Bootstrap. Piscopo, G., Bandaru, S. T., Giacalone, M., &
> Longobardi, M. (2025). Mathematics, 13(17), 2869.
> https://doi.org/10.3390/math13172869

## Installation

Install the development release from GitHub:

```r
install.packages("remotes", repos = "https://cloud.r-project.org")
remotes::install_github("saitejabandaru-in/nf-risk-stratification")
```

You can also build locally from a clone:

```bash
R CMD build .
R CMD INSTALL nfRiskStratification_0.1.0.tar.gz
```

## Required Data

The real clinical dataset is not included due to ethical and privacy
restrictions. Place an anonymized CSV at:

```text
data/nf_clinical_data.csv
```

Required columns:

| Column | Meaning |
| --- | --- |
| `HBA1C` | Glycemic control |
| `ALBUMINA` | Nutritional status |

Optional columns:

| Column | Meaning |
| --- | --- |
| `MORTO` | Mortality outcome |
| `AMPUTAZIONE` | Major amputation outcome |
| `PATIENT_ID` | Patient identifier |

An anonymized toy dataset is included for examples:

```r
example_path <- system.file(
  "extdata",
  "nf_clinical_data_example.csv",
  package = "nfRiskStratification"
)
```

## Quick Start

```r
library(nfRiskStratification)

data <- read_nf_data("data/nf_clinical_data.csv")

descriptive_stats(data)
npc_analysis(data)
bootstrap_ci(data, reps = 1000)
head(rank_patients(data), 10)
```

Run the full pipeline in one call:

```r
results <- run_nf_pipeline(path = "data/nf_clinical_data.csv")

results$descriptive
results$npc$global_p_values
results$bootstrap
head(results$ranking, 10)
```

## Legacy Scripts

The original top-level scripts still work and now call the package functions:

```r
source("descriptive_stats.R")
source("npc_analysis.R")
source("bootstrap_analysis.R")
source("ranking_analysis.R")
```

## Package API

| Function | Purpose |
| --- | --- |
| `read_nf_data()` | Read and validate an anonymized CSV dataset |
| `validate_nf_data()` | Validate required columns and normalize numeric fields |
| `descriptive_stats()` | Summarize clinical variables |
| `npc_analysis()` | Compute partial p-values and Fisher, Tippett, and Liptak global p-values |
| `bootstrap_ci()` | Compute percentile bootstrap confidence intervals for means |
| `rank_patients()` | Rank patients by aggregate clinical severity |
| `run_nf_pipeline()` | Run the complete workflow |

## Release Workflow

Tagged releases build and publish a source package automatically:

```bash
git tag v0.1.0
git push origin v0.1.0
```

GitHub Actions then runs package checks, builds
`nfRiskStratification_0.1.0.tar.gz`, and attaches it to the GitHub release.

## Repository Layout

```text
R/                         Package source
man/                       Function documentation
tests/testthat/            Unit tests
inst/extdata/              Example anonymized dataset
data/                      Private local dataset location, not packaged
.github/workflows/         R package checks and release automation
```

## Author

Sai Teja Bandaru  
Data Scientist & Clinical Analytics Researcher  
Universita degli Studi della Campania Luigi Vanvitelli
