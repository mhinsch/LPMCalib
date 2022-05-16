"""
Main simulation of the lone parent model 

under construction 
"""

import SocialSimulations: SocialSimulation

import SocialSimulations.LoneParentsModel: createPopulation, loadData!, setSimulationParameters


simProperties = setSimulationParameters()

lpmSimulation = SocialSimulation(createPopulation,simProperties)

loadData!(lpmSimulation)
