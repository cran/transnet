################################################################################
# sim.R
# Andrew Redd
# 10/23/2012
# 
# Part of R package transnet.
# Distributed under the terms of the Gnu Public License Version 3.
# 
# DESCRIPTION
# ===========
# 
# This file contains functions to call the Java code to simulate a hospital
# or ward.
# 
################################################################################


#' Simulate disease transmission with a hospital ward
#' 
#' @param transmission transmission rate for 1-1 contact transmission probability.
#' @param importation probability of present on admission.
#' @param detection sensitivity
#' @param ndays length of simulation
#' @param capacity max number of patients
#' @param meanstay mean number of days a patient stays in unit.
#' @param balance mean percent of capacity occupied.
#' @param testperpatday number of tests per patient day.
#' @param withinf should infection events be returned?
#' 
#' @family sim
#' @export
#' @examples
#' 
#' sim <- sim_ward(0.005, 0.10, 0.80, 30, 15, 7)
#' pt <- eventsToPT(sim)
#' 
#' 
sim_ward <- function( transmission, importation, detection, ndays, capacity
                    , meanstay, balance=0.8, testperpatday = 1/3, withinf=TRUE)
{
    simulator <- .jnew("jpsgcs.alun.infect.InfSimulator"
                      , as.double(transmission)
                      , as.double(importation)
                      , as.double(detection)
                      , as.double(ndays)
                      , as.integer(capacity)
                      , as.double(meanstay)
                      , as.double(balance)
                      , as.double(testperpatday)
                      , as.logical(withinf))
    results <- vector('list', 0)
    while(simulator$hasNext()){
        results <- c(results, list(convertEvent(simulator$nextEvent())))
    }
    return(Reduce(rbind, results))
}
convertEvent <- function(e){
    data.frame( time = e$time()
              , pid  = e$pat()
              , type = e$type())
}

#' convert a data frame of events to data frames of patients and tests.
#' 
#' @param events data frame of events
#' @param admit admission code
#' @param discharge discharge code
#' @param infection code
#' @param negtest code
#' @param postest code
#' 
#' @family sim
#' @importFrom reshape2 dcast
#' @importFrom plyr rename
#' @export
eventsToPT <- function(events
                      , admit=0, discharge=3, infection=4
                      , negtest = 1, postest=2)
{
    moves <- c(admit=admit, discharge=discharge, infection=infection)
    sevom <- structure(names(moves), names=paste(moves))
    move.events <- subset(events, events$type %in% moves)
    patients <- dcast(move.events, pid~type, value.var='time', fill=NA)
    patients <- rename(patients, sevom)
    
    tests <- subset(events, events$type %in% c(negtest, postest))
    tests$result <- tests$type == postest
    tests <- tests[c('pid', 'time', 'result')]
    list(patients=patients, test=tests)
}

