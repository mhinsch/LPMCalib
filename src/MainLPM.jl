"""
Main simulation of the lone parent model 

under construction 
"""

import SocialSimulations: SocialSimulation

import SocialSimulations.LoneParentsModel: createPopulation

plmSimulation = SocialSimulation(createPopulation,
                    Dict(:startTime=>0,
                         :finishTime=>3000,
                         :dt=>1))
