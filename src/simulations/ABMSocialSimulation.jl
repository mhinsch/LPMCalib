"""
Definition of a social simulation type. It resembles Agents.jl 
""" 

export ABMSocialSimulation 
using MultiABMs: AbstractABM
using MultiABMs: errorstep 

mutable struct ABMSocialSimulation <: AbstractABMSimulation  
    model::AbstractABM
    properties::Dict{Symbol,Any} 
    
    pre_model_steps::Vector{Function} 
    agent_steps::Vector{Function}       
    post_model_steps::Vector{Function} 

    function ABMSocialSimulation(abm::AbstractABM,properties::Dict{Symbol};
                                 example::AbstractExample=DummyExample()) 
        abmsimulation = new(abm,properties,[errorstep],[errorstep],[errorstep])
        setup!(abmsimulation,example)
        abmsimulation 
    end

    ABMSocialSimulation(createABM::Function,properties::Dict{Symbol};
                        example::AbstractExample=DummyExample()) = 
                            ABMSocialSimulation(createABM(),properties,example=example)

end 

