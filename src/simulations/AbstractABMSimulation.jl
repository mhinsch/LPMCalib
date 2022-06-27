
"""
    A concept for ABM simulation 
"""

using  MultiAgents.Util:    AbstractExample, DummyExample 

export AbstractABMSimulation
export attach_agent_step!, attach_pre_model_step!, attach_post_model_step!
export setup!, step!, run! 

"Abstract type for ABMs" 
abstract type AbstractABMSimulation <: AbstractSimulation end 

"""
    default setup the simulation stepping functions in the constructor 
    This guarantees that the client provides proper stepping functions 
    either by overloading this method or other explicit ways 
"""
setup!(::AbstractABMSimulation,::AbstractExample) = nothing  

# attaching a stepping function is done via a function call, 
# since data structure is subject to change, e.g. Vector{Function}

"attach an agent step function to the simulation"
function attach_agent_step!(simulation::AbstractABMSimulation,
                            agent_step::Function) 
    push!(simulation.agent_steps,agent_step)             
    nothing           
end  

"attach a pre model step function to the simualtion, i.e. before the executions of agent_step"
function attach_pre_model_step!(simulation::AbstractABMSimulation,
                                model_step::Function) 
    # simulation.pre_model_step = model_step 
    push!(simulation.pre_model_steps,model_step) 
    nothing
end 

"attach a pre model step function to the simualtion, i.e. before the executions of agent_step"
function attach_post_model_step!(simulation::AbstractABMSimulation,
                                 model_step::Function) 
    push!(simulation.post_model_steps,model_step)  
    nothing
end 

"step a simulation"
step!(simulation::AbstractABMSimulation,
      n::Int=1) = step!(simulation,
                        simulation.pre_model_steps, 
                        simulation.agent_steps,
                        simulation.post_model_steps,
                        n)

"Run a simulation of an ABM"
run!(simulation::AbstractABMSimulation;verbose::Bool=false) = 
                run!(simulation, 
                     simulation.pre_model_steps,
                     simulation.agent_steps,
                     simulation.post_model_steps,
                     verbose=verbose)

