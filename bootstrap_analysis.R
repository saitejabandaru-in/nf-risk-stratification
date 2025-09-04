# Bootstrap Confidence Intervals for HBA1C and ALBUMINA

library(boot)
data <- read.csv("data/nf_clinical_data.csv")

boot_func <- function(x, indices) mean(x[indices])

boot_results <- list(
  HBA1C = boot(data$HBA1C, statistic = boot_func, R = 1000),
  ALBUMINA = boot(data$ALBUMINA, statistic = boot_func, R = 1000)
)

cat("\nBootstrap CI for HBA1C:\n")
print(boot.ci(boot_results$HBA1C, type = "perc"))

cat("\nBootstrap CI for ALBUMINA:\n")
print(boot.ci(boot_results$ALBUMINA, type = "perc"))
