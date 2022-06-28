"""
Main specification of a Simulation type / quite similar to Agents.jl Simulation concept

This file is included in Simuilations module
"""

using Random
using XAgents:     AbstractAgent 
using MultiAgents.Util:   date2yearsmonths 

import MultiAgents: step!
export step!, run!  


abstract type AbstractSimulation end 

model(sim::AbstractSimulation)      = sim.model 
startTime(sim::AbstractSimulation)  = sim.properties[:startTime]
finishTime(sim::AbstractSimulation) = sim.properties[:finishTime]
dt(sim::AbstractSimulation)         = sim.properties[:dt]
seed(sim::AbstractSimulation)       = sim.properties[:seed]



# Other versions of the above function
#    model_step! is omitted 
#    n(model,s)::Function 
#    agent_step! function can be a dummystep 

#===
Stepping and simulation run function 
===# 

step!(
    simulation::AbstractSimulation, 
    agent_step!,
    model_step!,  
    n::Int=1,
    agents_first::Bool=true 
)  = step!(model(simulation),agent_step!,model_step!,n,agents_first)

step!(
    simulation::AbstractSimulation, 
    pre_model_step!,
    agent_step!,
    post_model_step!,  
    n::Int=1,
)  = step!(model(simulation),pre_model_step!,agent_step!,post_model_step!,n)

step!(
    simulation::AbstractSimulation, 
    pre_model_steps::Vector{Function},
    agent_steps,
    post_model_steps,  
    n::Int=1,
)  = step!(model(simulation),pre_model_steps,agent_steps,post_model_steps,n)


function verboseStep(simulation_step::Rational,yearly=true) 
    (year,month) = date2yearsmonths(simulation_step) 
    yearly && month == 0 ? println("conducting simulation step year $(year)") : nothing 
    yearly               ? nothing : println("conducting simulation step year $(year) month $(month+1)")
end

"""
Run a simulation using stepping functions
    - agent_step_function()
    - model_step_function
"""
function run!(simulation::AbstractSimulation,
              agent_step!,
              model_step!;
              verbose::Bool=false,yearly=true) 

    Random.seed!(seed(simulation))

    for simulation_step in range(startTime(simulation),finishTime(simulation),step=dt(simulation))
        verbose ? verboseStep(simulation_step,yearly) : nothing 
        step!(simulation,agent_step!,model_step!)
    end 

end 
 

"""
Run a simulation using stepping functions
    - agent_step_function()
    - model_step_function
"""
function run!(simulation::AbstractSimulation,
              pre_model_step!, 
              agent_step!,
              post_model_step!;
              verbose::Bool=false,yearly=true) 

    Random.seed!(seed(simulation))

    for simulation_step in range(startTime(simulation),finishTime(simulation),step=dt(simulation))
        verbose ? verboseStep(simulation_step,yearly) : nothing 
        step!(simulation,pre_model_step!,agent_step!,post_model_step!)
    end 

end 
 
"""
Run a simulation using stepping functions
    - agent_step_function()
    - model_step_function
"""
function run!(simulation::AbstractSimulation,
              pre_model_steps::Vector{Function}, 
              agent_steps,
              post_model_steps;
              verbose::Bool=false,yearly=true) 

    Random.seed!(seed(simulation))

    for simulation_step in range(startTime(simulation),finishTime(simulation),step=dt(simulation))
        verbose ? verboseStep(simulation_step,yearly) : nothing 
        step!(simulation,pre_model_steps,agent_steps,post_model_steps)
    end 

end 
 