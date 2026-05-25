\name{bootstrap_ci}
\alias{bootstrap_ci}
\title{Bootstrap mean confidence intervals}
\usage{
bootstrap_ci(data, variables = c("HBA1C", "ALBUMINA"), reps = 1000,
  conf = 0.95, seed = 2026)
}
\arguments{
\item{data}{A validated or raw clinical data frame.}
\item{variables}{Numeric columns to bootstrap.}
\item{reps}{Number of bootstrap resamples.}
\item{conf}{Confidence level between 0 and 1.}
\item{seed}{Optional random seed for reproducible intervals.}
}
\value{A data frame with percentile bootstrap confidence intervals.}
\description{Bootstrap mean confidence intervals}
