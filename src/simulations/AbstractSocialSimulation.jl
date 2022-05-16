"""
Main specification of a Social Simulation type

This file is included in SocialSimuilations module
"""

import Random 

export run!, setProperty!
import SocialABMs: step!

# At the moment no need for Abstract Social Simulation! 
abstract type AbstractSocialSimulation end 

model(sim::AbstractSocialSimulation)      = sim.model 
startTime(sim::AbstractSocialSimulation)  = sim.properties[:startTime]
finishTime(sim::AbstractSocialSimulation) = sim.properties[:finishTime]
dt(sim::AbstractSocialSimulation)         = sim.properties[:dt]
seed(sim::AbstractSocialSimulation)       = sim.properties[:seed]

"set property to a given vlaue"
function setProperty!(sim::AbstractSocialSimulation,symbol::Symbol,val) 
    symbol in keys(sim.properties) ? 
         sim.properties[symbol] = val :  
            error("$(symbol) is not a key in $(sim.properties)")
    nothing
end


"load data needed by the simulation"
loadData!(simulation::AbstractSocialSimulation) = error("Not implemented") 

# "define and initialize an elemantry ABM"
# initABMs!(simulation::AbstractSocialSimulation) = error("Not implemented") 

# "Establish a Multi ABM from the elemantry ABMs"
# function initMultiABMs end 

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
        # Outputing result to be improved later by using agents.jl 
        print("\n\nsample after step: $(simulation_step) :\n")
        print("======================================== \n\n") 
        @show model(simulation).agentsList[1:10]
    end 

end 