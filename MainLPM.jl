"""
Main simulation of the lone parent model 

under construction 
"""

using SocialABMs: MultiABM

# dummystep 

using LoneParentsModel.Loaders:    loadUKMapParameters, loadUKPopulationParameters
using LoneParentsModel.Declare:    createUKDemography 
using LoneParentsModel.Initialize: initializeDemography!
using LoneParentsModel.SimSetup:   loadSimulationParameters

using SocialABMs: dummystep 

using SocialSimulations: ABMSocialSimulation, MABMSimulation
using SocialSimulations: run!, attach_agent_step!, attach_model_step!  

import SocialSimulations: setup!, AbstractExample

# export setup!, LPMUKDemography 

# Example Name 

struct LPMUKDemography <: AbstractExample end 

# Model parameters 

ukmapParameters = loadUKMapParameters()
ukpopParameters = loadUKPopulationParameters() 
ukDemographyParameters = merge(ukmapParameters,ukpopParameters)

# Declaration and initialization of a MABM for a demography model of UK 

ukDemography = MultiABM(ukDemographyParameters,
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

function setup!(sim::ABMSocialSimulation,example::LPMUKDemography) 
    attach_agent_step!(sim,dummystep) 
    attach_model_step!(sim,dummystep)
    nothing 
end

function setup!(sim::MABMSimulation,example::LPMUKDemography) 
    #= 
    n = length(sim.simulations) 
    for i in 1:n 
        attach_agent_step!(simulations[i],X) 
        attach_model_step!(simulations[i],Y)
    end
    =# 
    nothing 
end

lpmDemographySim = MABMSimulation(ukDemography,simProperties, 
                                  example=LPMUKDemography())

run!(lpmDemographySim,verbose=true)