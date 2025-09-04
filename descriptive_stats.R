# Descriptive Statistics for HBA1C and ALBUMINA

library(dplyr)
data <- read.csv("data/nf_clinical_data.csv")

descriptive_stats <- data %>% summarise(
  HBA1C_MEAN = mean(HBA1C), HBA1C_MEDIAN = median(HBA1C),
  HBA1C_SD = sd(HBA1C), HBA1C_MIN = min(HBA1C), HBA1C_MAX = max(HBA1C),
  ALBUMINA_MEAN = mean(ALBUMINA), ALBUMINA_MEDIAN = median(ALBUMINA),
  ALBUMINA_SD = sd(ALBUMINA), ALBUMINA_MIN = min(ALBUMINA), ALBUMINA_MAX = max(ALBUMINA)
)

print(descriptive_stats)
