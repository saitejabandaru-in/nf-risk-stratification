.required_nf_columns <- c("HBA1C", "ALBUMINA")

.default_rank_directions <- c(
  HBA1C = "desc",
  ALBUMINA = "asc",
  MORTO = "desc",
  AMPUTAZIONE = "desc"
)

.clean_numeric <- function(x) {
  if (is.factor(x)) {
    x <- as.character(x)
  }
  suppressWarnings(as.numeric(x))
}

.clip_p_values <- function(p_values) {
  pmin(pmax(p_values, .Machine$double.eps), 1 - .Machine$double.eps)
}

.mean_bootstrap_ci <- function(x, reps, conf, seed) {
  x <- x[is.finite(x)]
  if (length(x) < 2) {
    return(c(mean = mean(x), lower = NA_real_, upper = NA_real_))
  }

  if (!is.null(seed)) {
    old_seed <- if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
      get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
    } else {
      NULL
    }
    on.exit({
      if (is.null(old_seed)) {
        if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
          rm(".Random.seed", envir = .GlobalEnv)
        }
      } else {
        assign(".Random.seed", old_seed, envir = .GlobalEnv)
      }
    }, add = TRUE)
    set.seed(seed)
  }

  draws <- replicate(reps, mean(sample(x, replace = TRUE), na.rm = TRUE))
  alpha <- 1 - conf
  c(
    mean = mean(x, na.rm = TRUE),
    lower = unname(stats::quantile(draws, probs = alpha / 2, na.rm = TRUE)),
    upper = unname(stats::quantile(draws, probs = 1 - alpha / 2, na.rm = TRUE))
  )
}

read_nf_data <- function(path = "data/nf_clinical_data.csv") {
  if (!file.exists(path)) {
    stop("Dataset not found at: ", path, call. = FALSE)
  }
  validate_nf_data(utils::read.csv(path, stringsAsFactors = FALSE))
}

validate_nf_data <- function(data, required = .required_nf_columns) {
  if (!is.data.frame(data)) {
    stop("`data` must be a data frame.", call. = FALSE)
  }

  missing_columns <- setdiff(required, names(data))
  if (length(missing_columns) > 0) {
    stop(
      "Missing required column(s): ",
      paste(missing_columns, collapse = ", "),
      call. = FALSE
    )
  }

  numeric_columns <- intersect(c(.required_nf_columns, "MORTO", "AMPUTAZIONE"), names(data))
  for (column in numeric_columns) {
    data[[column]] <- .clean_numeric(data[[column]])
  }

  all_missing <- vapply(data[required], function(x) all(is.na(x)), logical(1))
  if (any(all_missing)) {
    stop(
      "Required column(s) contain only missing or non-numeric values: ",
      paste(names(all_missing)[all_missing], collapse = ", "),
      call. = FALSE
    )
  }

  data
}

descriptive_stats <- function(data, variables = .required_nf_columns, na.rm = TRUE) {
  data <- validate_nf_data(data, required = intersect(.required_nf_columns, variables))
  variables <- intersect(variables, names(data))

  summaries <- lapply(variables, function(variable) {
    values <- .clean_numeric(data[[variable]])
    data.frame(
      variable = variable,
      n = sum(!is.na(values)),
      mean = mean(values, na.rm = na.rm),
      median = stats::median(values, na.rm = na.rm),
      sd = stats::sd(values, na.rm = na.rm),
      min = min(values, na.rm = na.rm),
      max = max(values, na.rm = na.rm),
      stringsAsFactors = FALSE
    )
  })

  do.call(rbind, summaries)
}

npc_analysis <- function(
  data,
  reference_values = c(HBA1C = 7, ALBUMINA = 2.8),
  alternative = "two.sided"
) {
  data <- validate_nf_data(data, required = names(reference_values))

  p_values <- vapply(names(reference_values), function(variable) {
    values <- .clean_numeric(data[[variable]])
    values <- values[is.finite(values)]
    if (length(values) < 2 || stats::sd(values) == 0) {
      return(NA_real_)
    }
    tryCatch(
      stats::t.test(values, mu = reference_values[[variable]], alternative = alternative)$p.value,
      error = function(e) NA_real_
    )
  }, numeric(1))

  valid <- p_values[is.finite(p_values)]
  if (length(valid) == 0) {
    global <- c(fisher = NA_real_, tippett = NA_real_, liptak = NA_real_)
  } else {
    clipped <- .clip_p_values(valid)
    fisher_stat <- -2 * sum(log(clipped))
    fisher <- stats::pchisq(fisher_stat, df = 2 * length(clipped), lower.tail = FALSE)
    tippett <- 1 - (1 - min(clipped)) ^ length(clipped)
    z_score <- sum(stats::qnorm(1 - clipped)) / sqrt(length(clipped))
    liptak <- stats::pnorm(z_score, lower.tail = FALSE)
    global <- c(fisher = fisher, tippett = tippett, liptak = liptak)
  }

  list(
    partial_p_values = p_values,
    bonferroni_p_values = stats::p.adjust(p_values, method = "bonferroni"),
    global_p_values = global,
    reference_values = reference_values
  )
}

bootstrap_ci <- function(
  data,
  variables = .required_nf_columns,
  reps = 1000,
  conf = 0.95,
  seed = 2026
) {
  if (reps < 100) {
    stop("`reps` must be at least 100.", call. = FALSE)
  }
  if (!is.numeric(conf) || length(conf) != 1 || conf <= 0 || conf >= 1) {
    stop("`conf` must be a single number between 0 and 1.", call. = FALSE)
  }

  data <- validate_nf_data(data, required = intersect(.required_nf_columns, variables))
  variables <- intersect(variables, names(data))

  intervals <- lapply(seq_along(variables), function(i) {
    variable <- variables[[i]]
    interval <- .mean_bootstrap_ci(
      .clean_numeric(data[[variable]]),
      reps = reps,
      conf = conf,
      seed = if (is.null(seed)) NULL else seed + i - 1
    )
    data.frame(
      variable = variable,
      mean = interval[["mean"]],
      conf_low = interval[["lower"]],
      conf_high = interval[["upper"]],
      conf_level = conf,
      reps = reps,
      stringsAsFactors = FALSE
    )
  })

  do.call(rbind, intervals)
}

rank_patients <- function(
  data,
  variables = intersect(names(.default_rank_directions), names(data)),
  directions = .default_rank_directions,
  id_col = "PATIENT_ID"
) {
  data <- validate_nf_data(data)
  variables <- intersect(variables, names(data))
  if (length(variables) == 0) {
    stop("No ranking variables were found in `data`.", call. = FALSE)
  }

  rank_frame <- data
  score_parts <- lapply(variables, function(variable) {
    values <- .clean_numeric(data[[variable]])
    direction <- directions[[variable]]
    if (is.null(direction) || is.na(direction)) {
      direction <- "desc"
    }
    if (!direction %in% c("asc", "desc")) {
      stop("Ranking direction for `", variable, "` must be 'asc' or 'desc'.", call. = FALSE)
    }
    rank_input <- if (identical(direction, "asc")) -values else values
    stats::rank(rank_input, ties.method = "average", na.last = "keep")
  })

  score_matrix <- do.call(cbind, score_parts)
  colnames(score_matrix) <- paste0("RANK_", variables)
  rank_frame <- cbind(rank_frame, as.data.frame(score_matrix))
  rank_frame$SEVERITY_SCORE <- rowSums(score_matrix, na.rm = TRUE)
  rank_frame$SEVERITY_RANK <- stats::rank(-rank_frame$SEVERITY_SCORE, ties.method = "first")

  ordered <- rank_frame[order(rank_frame$SEVERITY_RANK), , drop = FALSE]
  rownames(ordered) <- NULL

  if (id_col %in% names(ordered)) {
    ordered <- ordered[c(id_col, setdiff(names(ordered), id_col))]
  }
  ordered
}

run_nf_pipeline <- function(
  data = NULL,
  path = "data/nf_clinical_data.csv",
  bootstrap_reps = 1000,
  seed = 2026
) {
  if (is.null(data)) {
    data <- read_nf_data(path)
  } else {
    data <- validate_nf_data(data)
  }

  list(
    descriptive = descriptive_stats(data),
    npc = npc_analysis(data),
    bootstrap = bootstrap_ci(data, reps = bootstrap_reps, seed = seed),
    ranking = rank_patients(data)
  )
}
