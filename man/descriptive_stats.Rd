\name{descriptive_stats}
\alias{descriptive_stats}
\title{Compute descriptive clinical statistics}
\usage{descriptive_stats(data, variables = .required_nf_columns, na.rm = TRUE)}
\arguments{
\item{data}{A validated or raw clinical data frame.}
\item{variables}{Numeric columns to summarize.}
\item{na.rm}{Remove missing values before summarizing.}
}
\value{A data frame with one row per variable.}
\description{Compute descriptive clinical statistics}
