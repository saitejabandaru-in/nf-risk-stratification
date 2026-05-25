\name{npc_analysis}
\alias{npc_analysis}
\title{Run partial tests and NPC p-value combinations}
\usage{
npc_analysis(data, reference_values = c(HBA1C = 7, ALBUMINA = 2.8),
  alternative = "two.sided")
}
\arguments{
\item{data}{A validated or raw clinical data frame.}
\item{reference_values}{Named numeric reference values for one-sample tests.}
\item{alternative}{Alternative hypothesis passed to \code{stats::t.test()}.}
}
\value{A list with partial p-values, Bonferroni values, and global methods.}
\description{Run partial tests and NPC p-value combinations}
