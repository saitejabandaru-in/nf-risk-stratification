\name{rank_patients}
\alias{rank_patients}
\title{Rank patients by clinical severity}
\usage{
rank_patients(data, variables =
  intersect(names(.default_rank_directions),
  names(data)), directions = .default_rank_directions,
  id_col = "PATIENT_ID")
}
\arguments{
\item{data}{A validated or raw clinical data frame.}
\item{variables}{Columns to include in the severity score.}
\item{directions}{Named vector with \code{asc} for lower-is-riskier and \code{desc} for higher-is-riskier variables.}
\item{id_col}{Optional patient identifier column.}
}
\value{A data frame sorted from highest to lowest severity.}
\description{Rank patients by clinical severity}
