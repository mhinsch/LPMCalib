"""
Main simulation of the lone parent model 

under construction 
"""

using SocialABMs: MultiABM
using LoneParentsModel.Loaders:    loadUKMapParameters, loadUKPopulationParameters
using LoneParentsModel.Declare:    createUKDemography 
using LoneParentsModel.Initialize: initializeDemography!

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
                        
#=
using SocialSimulations: SocialSimulation

using SocialSimulations.LoneParentsModel: loadUKMapParameters, loadUKPopulationParameters, loadSimulationParameters

simProperties = loadSimulationParameters()

# lpmSimulation = SocialSimulation(createPopulation,simProperties)

# loadData!(lpmSimulation)

# lpmSimulation
=# 