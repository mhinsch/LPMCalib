
"""
    A concept for ABM simulation 
"""

export AbstractABMSimulation
export attach_agent_step!, attach_model_step!, setup!, step!, run! 

"Abstract type for ABMs" 
abstract type AbstractABMSimulation <: AbstractSocialSimulation end 

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
    simulation.agent_step = agent_step             
    nothing           
end  

"attach a model step function to the simualtion"
function attach_model_step!(simulation::AbstractABMSimulation,
                            model_step::Function) 
    simulation.model_step = model_step 
    nothing
end 

"step a simulation"
step!(simulation::AbstractABMSimulation,
      n::Int=1,
      agents_first::Bool=true) = step!(simulation,
                                       simulation.agent_step,
                                       simulation.model_step)

"Run a simulation of an ABM"
run!(simulation::AbstractABMSimulation;verbose::Bool=false) = 
                run!(simulation, 
                     simulation.agent_step,
                     simulation.model_step,
                     verbose=verbose)

