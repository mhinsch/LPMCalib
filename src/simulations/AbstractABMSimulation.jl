
"""
    A concept for ABM simulation 
"""

export AbstractABMSimulation
export attach_agent_step!, attach_model_step!, run! 

"Abstract type for ABMs" 
abstract type AbstractABMSimulation <: AbstractSocialSimulation end 

# "setup the simulation stepping functions"
setup!(::AbstractABMSimulation;
       example::AbstractExample=DummyExample()) = error("simulation setup not implemented") 

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


"""
Run a simulation
"""
run!(simulation::AbstractABMSimulation) = run!(simulation, 
                                               simulation.agent_step,
                                               simulation.model_step)
