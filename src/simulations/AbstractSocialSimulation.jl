"""
Main specification of a Social Simulation type

This file is included in SocialSimuilations module
"""

import Random 

export run!
using SocialABMs: step!

# At the moment no need for Abstract Social Simulation! 
abstract type AbstractSocialSimulation end 

model(sim::AbstractSocialSimulation)      = sim.model 
startTime(sim::AbstractSocialSimulation)  = sim.properties[:startTime]
finishTime(sim::AbstractSocialSimulation) = sim.properties[:finishTime]
dt(sim::AbstractSocialSimulation)         = sim.properties[:dt]
seed(sim::AbstractSocialSimulation)       = sim.properties[:seed]

"""
Run a simulation using stepping functions
    - agent_step_function()
    - model_step_function
"""
function run!(simulation::AbstractSocialSimulation,
              agent_step_function,
              model_step_function) 

    Random.seed!(seed(simulation))

    for simulation_step in range(startTime(simulation),finishTime(simulation),step=dt(simulation))
        step!(model(simulation),agent_step_function,model_step_function)
    end 

end 