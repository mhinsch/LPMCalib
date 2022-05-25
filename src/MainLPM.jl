"""
Main simulation of the lone parent model 

under construction 
"""

import SocialSimulations: SocialSimulation

import SocialSimulations.LoneParentsModel: createPopulation, loadData!, setSimulationParameters

import SocialSimulations.LoneParentsModel: loadUKMapParameters

import SocialAgents: Town
import SocialABMs: SocialABM 
import SocialABMs.LoneParentsModel: createUKDemography


ukmapProperties = loadUKMapParameters()

simProperties = setSimulationParameters()

(uktowns,ukhouses) = createUKDemography(ukmapProperties) # = SocialABM{Town}(createUKDemography,ukmapProperties)



# lpmSimulation = SocialSimulation(createPopulation,simProperties)

# loadData!(lpmSimulation)

# lpmSimulation
