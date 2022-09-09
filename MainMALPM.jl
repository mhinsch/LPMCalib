"""
Main simulation of the lone parent model 

under construction 

Run this script from shell as 
# julia MainMALPM.jl

from REPL execute it using 
> include("MainMALPM.jl")
"""

include("./loadLibsPath.jl")

if !occursin("multiagents",LOAD_PATH)
    push!(LOAD_PATH, "src/multiagents") 
end

using MultiAgents: MultiABM, initMultiAgents, MAVERSION
 
using LPM.ParamTypes.Loaders:    loadUKDemographyPars

using MALPM.Demography.Create:     LPMUKDemography, LPMUKDemographyOpt, createUKDemography 
using MALPM.Demography.Initialize: initializeDemography!
using MALPM.Demography.SimSetup:   loadSimulationParameters

using MultiAgents: MABMSimulation
using MultiAgents: run! 

initMultiAgents()                 # reset agents counter
@assert MAVERSION == v"0.2.2"   # ensure MultiAgents.jl latest update 

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
simProperties[:seed] = floor(Int, time())
lpmDemographySim = MABMSimulation(ukDemography,simProperties, 
                                  example=LPMUKDemography())


# Execution 

@time run!(lpmDemographySim)

lpmDemographySim 
