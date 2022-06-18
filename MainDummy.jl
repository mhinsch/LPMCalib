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


using  SocialABMs: SocialABM, population_step!,dummystep 
using  SocialSimulations: DummyExample
using  SocialSimulations: ABMSocialSimulation
using  SocialSimulations: run!, attach_model_step!, attach_agent_step! 
import SocialSimulations: setup!
using Dummy: createPopulation 


function setup!(simulation::ABMSocialSimulation,
                ::DummyExample) 
     attach_agent_step!(simulation,dummystep)
     attach_model_step!(simulation,population_step!) 
end

dummySimulation = ABMSocialSimulation(createPopulation,
                                        Dict(:startTime=>1990,
                                             :finishTime=>2030,
                                             :dt=>1//12,
                                             :seed=>floor(Int,time())), 
                                        example = DummyExample())
println("Sample of initial population")

@show dummySimulation.model.agentsList[1:10] 

println()
println()

# attach_model_step!(dummySimulation,population_step!) 

run!(dummySimulation,verbose=true)

println("Sample population after simulation")
@show dummySimulation.model.agentsList[1:10]
 


