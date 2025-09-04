# Global Severity Ranking of Patients using NPC

library(dplyr)
data <- read.csv("data/nf_clinical_data.csv")

ranked <- data %>%
  mutate(across(everything(), ~ rank(., ties.method = "average"), .names = "RANK_{.col}")) %>%
  mutate(RANK_GLOBALE = rowSums(select(., starts_with("RANK_")))) %>%
  arrange(RANK_GLOBALE)

cat("\nTop 10 Most Severe Patients:\n"); print(head(ranked, 10))
