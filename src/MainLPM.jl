"""
Main simulation of the lone parent model 

under construction 
"""

using SocialSimulations: SocialSimulation

using SocialSimulations.LoneParentsModel: loadUKMapParameters, loadUKPopulationParameters

# using SocialAgents: Town
using SocialABMs: MultiABM
using SocialABMs.LoneParentsModel: createUKDemography


ukmapParameters = loadUKMapParameters()
ukpopParameters = loadUKPopulationParameters() 
ukDemographyParameters = merge(ukmapParameters,ukpopParameters)

# simProperties = setSimulationParameters()

# (uktowns,ukhouses,ukpopulation) = createUKDemography(ukDemographyParameters) # = SocialABM{Town}(createUKDemography,ukmapProperties)

ukDemography = MultiABM(ukDemographyParameters,
                         declare=createUKDemography)


# lpmSimulation = SocialSimulation(createPopulation,simProperties)

# loadData!(lpmSimulation)

# lpmSimulation
