"""
Definition of a social simulation type. It resembles Agents.jl 
""" 

export ABMSocialSimulation 
using SocialABMs: AbstractSocialABM

mutable struct ABMSocialSimulation <: AbstractSocialSimulation  
    model::AbstractSocialABM
    properties::Dict{Symbol,Any}
    #=
    ABMSocialSimulation(model::AbstractSocialABM,properties::Dict{Symbol})
        = new(model,properties)
    =# 
    ABMSocialSimulation(createABM::Function,properties::Dict{Symbol}) = new(createABM(),copy(properties))
end 

# default cors .

# Simulation setup phasze 
# attaching simulations ... 