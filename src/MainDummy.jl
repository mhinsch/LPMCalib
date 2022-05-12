"""
An example of a dummy simulation of an ABM model.

The ABM model corresponds to a population of agents. 
Some agents are living together in a house.
They are currently ageing together. 
""" 


using SocialSimulations: SocialSimulation, run! 
using SocialABMs: SocialABM, dummystep, population_step!

include("simulations/Dummy.jl")


currdir = pwd()

if ! endswith(currdir,"LoneParentsModel.jl/src")
    @show currdir
    error("this script has to be executed within the main source folder of LoneParentModel.jl")
end 
if ! (currdir in LOAD_PATH) 
    push!(LOAD_PATH,currdir) 
end 


dummySimulation = SocialSimulation(createDummyPopulation,
                                   Dict(:startTime=>1990,
                                        :finishTime=>2030,
                                        :dt=>1))

# print(dummySimulation.model)

run!(dummySimulation,dummystep,population_step!)
 

# This could return a list of elemantry ABMs (ABMsList) 
# (towns,houses,population) =
#    SocialDummySimulation.initDummyABMs() 

# Create a MultiABM 
# 
# After a Multi ABM has been initialized run the simulation 
# e.g.
# createMultiABM(ABMsList) 
# 

# SocialDummySimulation.runDummyExample(population)


