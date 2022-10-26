"""
Main simulation of the lone parent model 
light version without I/O, gui etc. just 
for checking performance 

Run this script from shell as 
# julia mainMALight.jl

from REPL execute it using 
> include("MainMALight.jl")
"""

include("./loadLibsPath.jl")

addToLoadPath!("src")
addToLoadPath!("src/multiagents") 
addToLoadPath!("../MultiAgents.jl")

include("src/lpm/demography/demographydata.jl")
include("mainHelpers.jl")

using MultiAgents: ABMSimulation 
using MultiAgents: run!

using LPM.ParamTypes: SimulationPars, seed!
using LPM.ParamTypes: DemographyPars

using MALPM.Demography: MAModel, LPMUKDemography, LPMUKDemographyOpt 
using MALPM.Demography.SimSetup: setup! 

const simPars = SimulationPars(seed=0,
                                verbose=false,
                                sleeptime=0,
                                checkassumption=false)

seed!(simPars)

const pars = DemographyPars()
# pars.poppars.initialPop = 500   # temporarily , to be improved 

const data = loadDemographyData(pars.datapars)

const model = setupModel(pars)

ukDemography = MAModel(model,pars,data)

lpmDemographySim = ABMSimulation(simPars,setupEnabled = false)
setup!(lpmDemographySim,LPMUKDemography()) 

# Execution 
@time run!(ukDemography,lpmDemographySim,LPMUKDemographyOpt())



