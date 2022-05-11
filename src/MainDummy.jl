"""
An example of a dummy simulation of an ABM model.

The ABM model corresponds to a population of agents. 
Some agents are living together in a house.
They are currently ageing together. 
""" 

using SocialDummySimulation

currdir = pwd()

if ! endswith(currdir,"LoneParentsModel.jl/src")
    @show currdir
    error("this script has to be executed within the main source folder of LoneParentModel.jl")
end 
if ! (currdir in LOAD_PATH) 
    push!(LOAD_PATH,currdir) 
end 

SocialDummySimulation.loadData() 

# This could return a list of elemantry ABMs (ABMsList) 
(towns,houses,population) =
    SocialDummySimulation.initDummyABMs() 

# Create a MultiABM 
# 
# After a Multi ABM has been initialized run the simulation 
# e.g.
# createMultiABM(ABMsList) 
# 

SocialDummySimulation.runDummyExample(population)