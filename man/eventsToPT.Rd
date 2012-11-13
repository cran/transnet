\name{eventsToPT}
\alias{eventsToPT}
\title{convert a data frame of events to data frames of patients and tests.}
\usage{
  eventsToPT(events, admit = 0, discharge = 3,
    infection = 4, negtest = 1, postest = 2)
}
\arguments{
  \item{events}{data frame of events}

  \item{admit}{admission code}

  \item{discharge}{discharge code}

  \item{infection}{code}

  \item{negtest}{code}

  \item{postest}{code}
}
\description{
  convert a data frame of events to data frames of patients
  and tests.
}
\seealso{
  Other sim: \code{\link{sim_ward}}
}

