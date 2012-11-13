\name{sim_ward}
\alias{sim_ward}
\title{Simulate disease transmission with a hospital ward}
\usage{
  sim_ward(transmission, importation, detection, ndays,
    capacity, meanstay, balance = 0.8, testperpatday = 1/3,
    withinf = TRUE)
}
\arguments{
  \item{transmission}{transmission rate for 1-1 contact
  transmission probability.}

  \item{importation}{probability of present on admission.}

  \item{detection}{sensitivity}

  \item{ndays}{length of simulation}

  \item{capacity}{max number of patients}

  \item{meanstay}{mean number of days a patient stays in
  unit.}

  \item{balance}{mean percent of capacity occupied.}

  \item{testperpatday}{number of tests per patient day.}

  \item{withinf}{should infection events be returned?}
}
\description{
  Simulate disease transmission with a hospital ward
}
\examples{
sim <- sim_ward(0.005, 0.10, 0.80, 30, 15, 7)
pt <- eventsToPT(sim)
}
\seealso{
  Other sim: \code{\link{eventsToPT}}
}

