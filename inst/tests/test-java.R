library(testthat)
library(transnet)

if(F){  # used to generate data which is cached
  library(harvestr)
  library(transsim)
  library(plyr)
  
  sim <- farm(gather(1, seed = 20120501),
    doSim(capacity=30, transmission=0.001, importation=0.05, test_rate=8
       , stay=5, length=90, balance=balance, fn=.1, fp=0))[[1]]
  cuts <- 1
  ward <- list(
    patients= mutate(sim$patients, 
      admit     = floor(cuts*admit),
      discharge = floor(cuts*discharge),
      infection = floor(cuts*infection)),
    tests   = mutate(sim$tests,
      time      = floor(cuts*time))
  )
  save(ward, file = "test.RData")
}


context("testing Java interface")
test_that("Java interface", {
  datafile <- system.file("tests", "test.RData", package="transnet", mustWork=T)
  load(datafile)
  
  model <- new("TransmissionModel", ward$patients, ward$tests
              , show.net=F, progress=F, deltatime=1)
  model$run(10)
  model$run(10, TRUE)
})



