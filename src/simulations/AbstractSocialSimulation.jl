"""
Main specification of a Social Simulation type

This file is included in SocialSimuilations module
"""

using Random

export run!, attach_model_step!, attach_agent_step!
using SocialABMs: step!

# At the moment no need for Abstract Social Simulation! 
abstract type AbstractSocialSimulation end 

model(sim::AbstractSocialSimulation)      = sim.model 
startTime(sim::AbstractSocialSimulation)  = sim.properties[:startTime]
finishTime(sim::AbstractSocialSimulation) = sim.properties[:finishTime]
dt(sim::AbstractSocialSimulation)         = sim.properties[:dt]
seed(sim::AbstractSocialSimulation)       = sim.properties[:seed]


# "setup the simulation stepping functions"
function setup!(::AbstractSocialSimulation) end 

# attaching a stepping function is done via a function call, 
# since data structure is subject to change, e.g. Vector{Function}

"attach an agent step function to the simulation"
function attach_agent_step!(simulation::AbstractSocialSimulation,
                            agent_step::Function) 
    simulation.agent_step = agent_step             
    nothing           
end  

"attach a model step function to the simualtion"
function attach_model_step!(simulation::AbstractSocialSimulation,
                            model_step::Function) 
    simulation.model_step = model_step 
    nothing
end 

#= 
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
=# 



"""
Run a simulation
"""
function run!(simulation::AbstractSocialSimulation) 

    Random.seed!(seed(simulation))

    for simulation_step in range(startTime(simulation),finishTime(simulation),step=dt(simulation))
        step!(model(simulation),simulation.agent_step,simulation.model_step)
    end 

end 