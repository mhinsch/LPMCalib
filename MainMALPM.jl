"""
Main simulation of the lone parent model 

under construction 

Run this script from shell as 
# julia MainMALPM.jl

from REPL execute it using 
> include("MainMALPM.jl")
"""

include("./loadLibsPath.jl")

using MultiAgents: MultiABM
 
using LPM.Parameters.Loaders:    loadUKDemographyPars

using MALPM.Demography.Create:     LPMUKDemography, LPMUKDemographyOpt, createUKDemography 
using MALPM.Demography.Initialize: initializeDemography!
using MALPM.Demography.SimSetup:   loadSimulationParameters

using MultiAgents: MABMSimulation
using MultiAgents: run! 

ukDemographyPars = loadUKDemographyPars() 

# Declaration and initialization of a MABM for a demography model of UK 


ukDemography = MultiABM(ukDemographyPars,
                        declare=createUKDemography,
                        initialize=initializeDemography!)

@show "Town Samples: \n"     
@show ukDemography.abms[1].agentsList[1:10]
println(); println(); 
                        
@show "Houses samples: \n"      
@show ukDemography.abms[2].agentsList[1:10]
println(); println(); 
                        
@show "population samples : \n" 
@show ukDemography.abms[3].agentsList[1:10]
println(); println(); 


# Declaration of a simulation 

simProperties = loadSimulationParameters()
lpmDemographySim = MABMSimulation(ukDemography,simProperties, 
                                  example=LPMUKDemographyOpt())


#=
# Execution 

run!(lpmDemographySim,verbose=true)

lpmDemographySim
=# 