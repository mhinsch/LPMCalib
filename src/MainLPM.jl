"""
Main simulation of the lone parent model 

under construction 
"""

currdir = pwd()

if ! endswith(currdir,"LoneParentsModel.jl/src")
    @show currdir
    error("this script has to be executed within the main source folder of LoneParentModel.jl")
end 
if ! (currdir in LOAD_PATH) 
    push!(LOAD_PATH,currdir) 
end 

