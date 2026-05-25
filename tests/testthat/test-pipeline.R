test_that("pipeline returns all expected sections", {
  path <- system.file("extdata", "nf_clinical_data_example.csv",
    package = "nfRiskStratification"
  )
  data <- read_nf_data(path)

  result <- run_nf_pipeline(data, bootstrap_reps = 100)

  expect_named(result, c("descriptive", "npc", "bootstrap", "ranking"))
  expect_true(all(c("HBA1C", "ALBUMINA") %in% result$descriptive$variable))
  expect_named(result$npc, c(
    "partial_p_values",
    "bonferroni_p_values",
    "global_p_values",
    "reference_values"
  ))
  expect_true(all(c("fisher", "tippett", "liptak") %in% names(result$npc$global_p_values)))
  expect_equal(nrow(result$bootstrap), 2)
  expect_equal(nrow(result$ranking), nrow(data))
})

test_that("validation reports missing required columns", {
  expect_error(validate_nf_data(data.frame(HBA1C = c(7.1, 8.0))), "ALBUMINA")
})

test_that("ranking orders severe patients first", {
  data <- data.frame(
    PATIENT_ID = c("low", "high"),
    HBA1C = c(6.5, 9.5),
    ALBUMINA = c(3.5, 2.0),
    MORTO = c(0, 1),
    AMPUTAZIONE = c(0, 1)
  )

  ranked <- rank_patients(data)
  expect_equal(ranked$PATIENT_ID[[1]], "high")
})
