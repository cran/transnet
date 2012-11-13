# TransmissionNetwork.R
# 2011-06-07
# Andrew Redd
# 
# Part of R package transnet.
# Distributed under the terms of the Gnu Public License Version 3.



#' Transmission Model Class
#'
#' Fits a transmission model for single ward or hospital.
#' Wards are assumed to be open in that there are admissions and discharges.
#' @import rJava
#' @export
TransmissionModel <- setRefClass("TransmissionModel",
  fields = list( sampler="jobjRef"),
  methods= list(
    initialize = function(patient.data, test.data, 
      patient.vars = plyr::.(pid=pid, admit=admit, discharge=discharge), 
      test.vars = plyr::.(pid=pid, time=time, result=result),
      show.net=interactive(), progress=interactive(), progress.type='text',
      deltatime=1){
      #' Initializes the java mcmc sampler with the patient and swab data.
      #' @param patient.data Patients data frame
      #' @param test.data tests data frame , must have a variable identifying patients in patient.data. 
      #' @param patient.vars mapping for the variables in the patient.data.  Use .() notation.  See Details
      #' @param test.vars  mapping for tests variables.  Use .() notation.  See Details.
	    #' @param deltatime delta time, the discrete time unit.
      #' 
      #' For mapping variables for the patient and test data use the .() function.  For patients there must be 
      #' declared variables pid, admit, and discharge.  Example ".(pid=Patient.ID, admit=Admit.Time, discharge=Discharge.Time)
      #' For tests data the variables pid, result, and result must be declared.
      
      #checking
      if(!nrow(patient.data) || !nrow(test.data)) stop("Data must be provided.")      
      if(!all(c('pid','admit','discharge')%in% names(patient.vars))) stop("Bad patient variable mapping")
      if(!all(c('pid','time','result')%in% names(test.vars))) stop("Bad test variable mappings")

      s = .jnew("java.util.ArrayList")
      #Load admits and discharges
      if(progress) message("(1/3) Loading patient data.")
      load.patient<-function(pdata){
        stopifnot(NROW(pdata)==1)
        with(pdata,{stopifnot(
             .jcall(s,"Z",'add',.jcast(.jnew("jpsgcs.alun.infect.Event", as.integer(eval(patient.vars$admit)), as.integer(eval(patient.vars$pid)), 0L)))
             &&
             .jcall(s,"Z",'add',.jcast(.jnew("jpsgcs.alun.infect.Event", as.integer(eval(patient.vars$discharge)), as.integer(eval(patient.vars$pid)), 3L))))
        })
      }
      d_ply(patient.data, patient.vars['pid'], load.patient,
            .progress=ifelse(progress,progress.type,"none"))
      #Load tests data
      if(progress)message("(2/3) Loading test data.")
      load.test<-function(sdata){
        stopifnot(NROW(sdata)==1)
        with(sdata,{
          stopifnot(.jcall(s,"Z","add",
              .jcast(.jnew("jpsgcs.alun.infect.Event", as.integer(eval(test.vars$time)), as.integer(eval(test.vars$pid)), ifelse(as.integer(eval(test.vars$result)), 2L, 1L)))
            ))
        })
      }
      d_ply(data.frame(test_id=seq_len(NROW(test.data)),test.data),.(test_id), load.test, .progress=ifelse(progress, progress.type,'none'))
      #check length of event collection
      stopifnot(.jcall(s, "I",'size')==NROW(patient.data)*2+ NROW(test.data))
      if(progress) message("(3/3) Creating mcmc sampler.")
      sampler <<- .jnew("jpsgcs.alun.infect.OneUnitSampler",.jcast(s,"java.util.Collection"),show.net, deltatime)
      .self
    },
    run=function(nruns, max=F){
      parNames <- (parNames<-.jcall(sampler, "[S","parNames"))
      time.java<-system.time(pars <- structure(matrix(.jcall(sampler, "[D","run", as.integer(nruns), as.logical(max)),nrow=nruns, ncol=length(parNames), byrow=T),dimnames=list(NULL,parNames)))
      structure(as.data.frame(pars), run.time=time.java)
    }
  )
)
TransmissionModel$lock("sampler")

