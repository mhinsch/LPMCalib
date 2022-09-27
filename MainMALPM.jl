"""
Main simulation of the lone parent model 

under construction 

Run this script from shell as 
# julia MainMALPM.jl

from REPL execute it using 
> include("MainMALPM.jl")
"""

include("./loadLibsPath.jl")

using MultiAgents: initMultiAgents, MAVERSION

initMultiAgents()                 # reset agents counter
@assert MAVERSION == v"0.2.3"   # ensure MultiAgents.jl latest update 

using MultiAgents: MultiABM
 
using LPM.ParamTypes.Loaders:    loadUKDemographyPars

using MALPM.Demography.Create:     LPMUKDemography, LPMUKDemographyOpt, createUKDemography 
using MALPM.Demography.Initialize: initializeDemography!
using MALPM.Demography.SimSetup:   loadSimulationParameters

using MultiAgents: MABMSimulation
using MultiAgents: run! 

const simProperties = loadSimulationParameters()
const ukDemographyPars = loadUKDemographyPars() 

# Declaration and initialization of a MABM for a demography model of UK 


ukDemography = MultiABM(ukDemographyPars,
                        declare=createUKDemography,
                        initialize=initializeDemography!)

if simProperties.verbose
    @show "Town Samples: \n"     
    @show ukDemography.abms[1].agentsList[1:10]
    println(); println(); 
                        
    @show "Houses samples: \n"      
    @show ukDemography.abms[2].agentsList[1:10]
    println(); println(); 
                        
    @show "population samples : \n" 
    @show ukDemography.abms[3].agentsList[1:10]
    println(); println(); 
end 

# Declaration of a simulation 
lpmDemographySim = MABMSimulation(ukDemography,simProperties, 
                                  # example=LPMUKDemography())
                                  example=LPMUKDemographyOpt())


# Execution 

@time run!(lpmDemographySim)
