"""
Main simulation of the lone parent model 

Run this script from shell as 
# julia mainMA.jl

from REPL execute it using 
> include("mainMA.jl")
"""

include("mainMAHelpers.jl")

mainConfig = Light() 
# mainConfig = WithInputFiles()

lpmExample = LPMUKDemography()    # remove deads
# lpmExample = LPMUKDemographyOpt()   # don't remove deads 

const simPars, pars = loadParameters(mainConfig) 

const model = setupModel(pars)

const logfile = setupLogging(simPars,mainConfig)

const demoData = loadDemographyData(pars.datapars)

const ukDemography = MAModel(model,pars,demoData)

const lpmDemographySim = ABMSimulation(simPars,setupEnabled = false)
setup!(lpmDemographySim,lpmExample) 
 
# Execution 
@time run!(ukDemography,lpmDemographySim,lpmExample)

closeLogfile(logfile,mainConfig)
 
