"""
Main specification of a Social Simulation type

This file is included in SocialSimuilations module
"""

using Random
using SocialAgents: AbstractAgent 
using SocialABMs:   AbstractABM 

import SocialABMs: step!, run! 

export step!, run!  
export attach_model_step!, attach_agent_step!


# At the moment no need for Abstract Social Simulation! 
abstract type AbstractSocialSimulation end 

model(sim::AbstractSocialSimulation)      = sim.model 
startTime(sim::AbstractSocialSimulation)  = sim.properties[:startTime]
finishTime(sim::AbstractSocialSimulation) = sim.properties[:finishTime]
dt(sim::AbstractSocialSimulation)         = sim.properties[:dt]
seed(sim::AbstractSocialSimulation)       = sim.properties[:seed]



# Other versions of the above function
#    model_step! is omitted 
#    n(model,s)::Function 
#    agent_step! function can be a dummystep 

#===
Stepping and simulation run function 
===# 

step!(
    simulation::AbstractSocialSimulation, 
    agent_step!,
    model_step!,  
    n::Int=1,
    agents_first::Bool=true 
)  = step!(model(simulation),agent_step!,model_step!,n,agents_first)

"""
Run a simulation using stepping functions
    - agent_step_function()
    - model_step_function
"""
function run!(simulation::AbstractSocialSimulation,
              agent_step!,
              model_step!) 

    Random.seed!(seed(simulation))

    for simulation_step in range(startTime(simulation),finishTime(simulation),step=dt(simulation))
        step!(simulation,agent_step!,model_step!)
    end 

end 
 
