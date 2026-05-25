\name{run_nf_pipeline}
\alias{run_nf_pipeline}
\title{Run the full NF risk stratification pipeline}
\usage{
run_nf_pipeline(data = NULL, path = "data/nf_clinical_data.csv",
  bootstrap_reps = 1000, seed = 2026)
}
\arguments{
\item{data}{A clinical data frame, or \code{NULL} to read from \code{path}.}
\item{path}{CSV path used when \code{data} is \code{NULL}.}
\item{bootstrap_reps}{Number of bootstrap resamples.}
\item{seed}{Optional seed passed to \code{bootstrap_ci()}.}
}
\value{A named list with descriptive statistics, NPC results, bootstrap intervals, and patient ranking.}
\description{Run the full NF risk stratification pipeline}
