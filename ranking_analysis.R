# Global Severity Ranking of Patients using NPC

if (requireNamespace("nfRiskStratification", quietly = TRUE)) {
  library(nfRiskStratification)
} else {
  source("R/nf-risk-stratification.R")
}

data <- read_nf_data("data/nf_clinical_data.csv")
ranked <- rank_patients(data)

cat("\nTop 10 most severe patients:\n")
print(utils::head(ranked, 10))
