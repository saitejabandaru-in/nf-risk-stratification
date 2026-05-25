# Descriptive Statistics for HBA1C and ALBUMINA

if (requireNamespace("nfRiskStratification", quietly = TRUE)) {
  library(nfRiskStratification)
} else {
  source("R/nf-risk-stratification.R")
}

data <- read_nf_data("data/nf_clinical_data.csv")
print(descriptive_stats(data))
