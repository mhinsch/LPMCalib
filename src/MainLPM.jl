"""
Main simulation of the lone parent model 

under construction 
"""

using SocialSimulations: SocialSimulation

using SocialSimulations.LoneParentsModel: loadUKMapParameters, loadUKPopulationParameters

# using SocialAgents: Town
using SocialABMs: MultiABM
using SocialABMs.LoneParentsModel: createUKDemography


# Model parameters 
ukmapParameters = loadUKMapParameters()
ukpopParameters = loadUKPopulationParameters() 
ukDemographyParameters = merge(ukmapParameters,ukpopParameters)

# Declaration and initialization of a MABM for a demography model of UK 
ukDemography = MultiABM(ukDemographyParameters,
                        declare=createUKDemography)

# simProperties = setSimulationParameters()

# lpmSimulation = SocialSimulation(createPopulation,simProperties)

# loadData!(lpmSimulation)

# lpmSimulation
