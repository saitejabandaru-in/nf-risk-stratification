\name{validate_nf_data}
\alias{validate_nf_data}
\title{Validate a necrotizing fasciitis clinical dataset}
\usage{validate_nf_data(data, required = c("HBA1C", "ALBUMINA"))}
\arguments{
\item{data}{A data frame with at least \code{HBA1C} and \code{ALBUMINA}.}
\item{required}{Character vector of required column names.}
}
\value{A normalized data frame with required clinical columns converted to numeric.}
\description{Validate a necrotizing fasciitis clinical dataset}
