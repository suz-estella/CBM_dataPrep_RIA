
### DEFINE MODULE ----

defineModule(sim, list(
  name = "CBM_dataPrep_RIA",
  description = "CBM data preparation module for the RIA study area",
  version = list(SpaDES.core = "1.0.2", CBM_dataPrep_RIA = "0.0.2"),
  authors = c(
    person("Celine", "Boisvenue", email = "Celine.Boisvenue@nrcan-rncan.gc.ca", role = c("aut", "cre")),
    person("Susan",  "Murray",    email = "susan.murray@nrcan-rncan.gc.ca",     role = "ctb")
  ),
  timeunit = "year",
  parameters = rbind(
    defineParameter(
      ".useCache", "logical", default = FALSE, NA, NA, desc = "Use caching for module")
  ),
  inputObjects = rbind(

  ),
  outputObjects = rbind(

  )
))


### SCHEDULE EVENTS ----

doEvent.CBM_dataPrep_RIA <- function(sim, eventTime, eventType, debug = FALSE){
  switch(
    eventType,
    init = {
      sim <- Init(sim)
    },
    warning(noEventWarning(sim))
  )
  return(invisible(sim))
}


### EVENT FUNCTION: INIT ----

Init <- function(sim){



}


### INPUT OBJECTS ----

.inputObjects <- function(sim){



}



