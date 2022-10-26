"""
Main simulation of the lone parent model 

Run this script from shell as 
# julia mainMA.jl

from REPL execute it using 
> include("mainMA.jl")
"""

include("mainMAHelpers.jl")

const mainExample = Light() 
# const mainExample = WithInputFiles()

const simPars, pars = loadParameters(mainExample) 

const model = setupModel(pars)

const logfile = setupLogging(simPars,mainExample)

const data = loadDemographyData(pars.datapars)

const ukDemography = MAModel(model,pars,data)

const lpmDemographySim = ABMSimulation(simPars,setupEnabled = false)
setup!(lpmDemographySim,LPMUKDemography()) 
 
# Execution 
@time run!(ukDemography,lpmDemographySim,LPMUKDemographyOpt())

closeLogfile(logfile,mainExample)
 
