"""
Main simulation of the lone parent model 

under construction 
"""

using SocialABMs: MultiABM

# dummystep 

using LoneParentsModel.Loaders:    loadUKMapParameters, loadUKPopulationParameters
using LoneParentsModel.Declare:    createUKDemography 
using LoneParentsModel.Initialize: initializeDemography!
using LoneParentsModel.SimSetup:   loadSimulationParameters, LPMUKDemography

using SocialSimulations: MABMSimulation
using SocialSimulations: run! 

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

lpmDemographySim = MABMSimulation(ukDemography,simProperties, 
                                  example=LPMUKDemography())

# Execution 

run!(lpmDemographySim,verbose=true)

lpmDemographySim
 