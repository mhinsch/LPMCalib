"""
Main simulation of the lone parent model 

under construction 

Run this script from shell as 
# julia MainMALPM.jl

from REPL execute it using 
> include("MainMALPM.jl")
"""

using Random

include("./loadLibsPath.jl")

addToLoadPath!("src")
addToLoadPath!("src/multiagents") 
addToLoadPath!("../MultiAgents.jl")

include("mainHelpers.jl")

const simPars, pars = loadParameters(ARGS) 

Random.seed!(simPars.seed)

const model = setupModel(pars)

const logfile = setupLogging(simPars)


using MultiAgents: initMultiAgents, MAVERSION
using MultiAgents: AbstractMABM, ABMSimulation 
using MultiAgents: run!

initMultiAgents()                 # reset agents counter
@assert MAVERSION == v"0.3"   # ensure MultiAgents.jl latest update 



using MALPM.Demography: MAModel, LPMUKDemography, LPMUKDemographyOpt 
using MALPM.Demography.SimSetup: setup! 


ukDemography = MAModel(model,pars)

lpmDemographySim = ABMSimulation(simPars,setupEnabled = false)
setup!(lpmDemographySim,LPMUKDemography()) 
 
# Execution 
@time run!(ukDemography,lpmDemographySim,LPMUKDemographyOpt())

close(logfile)
