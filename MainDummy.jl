"""
An example of a dummy simulation of an ABM model.

The ABM model corresponds to a population of agents. 
Some agents are living together in a house.
They are currently ageing together. 

to run this script, LoneParentsModel.jl package has to
be in the load path. Within REPL, execute:

julia> push!(LOAD_PATH,"/path/to/LoneParentsModel.jl/src")
julia> include("this_script.jl")
""" 


using  MultiAgents: ABM, dummystep 
using  MultiABMs: population_step!

using  SomeUtil:    AbstractExample, DummyExample 
using  MultiAgents: ABMSimulation
using  MultiAgents: run!, attach_pre_model_step!, attach_post_model_step!, attach_agent_step! 
import MultiAgents: setup!
using Dummy: createPopulation 


function setup!(simulation::ABMSimulation,
                ::DummyExample) 
     simulation.agent_steps = [dummystep] 
     simulation.pre_model_steps = [population_step!]  
     simulation.post_model_steps = [dummystep] 
     nothing  
end

dummySimulation = ABMSimulation(createPopulation,
                                        Dict(:startTime=>1990,
                                             :finishTime=>2030,
                                             :dt=>1//12,
                                             :seed=>floor(Int,time())), 
                                        example = DummyExample())
println("Sample of initial population")

@show dummySimulation.model.agentsList[1:10] 

println()
println()

run!(dummySimulation,verbose=true)

println("Sample population after simulation")
@show dummySimulation.model.agentsList[1:10]
 


