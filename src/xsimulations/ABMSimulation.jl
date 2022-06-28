"""
Definition of an ABM-Simulation type.
""" 

export ABMSimulation 

using MultiAgents: errorstep 

using MultiAgents.Util:    AbstractExample, DummyExample 

mutable struct ABMSimulation <: AbstractABMSimulation  
    model::AbstractABM
    properties::Dict{Symbol,Any} 
    
    pre_model_steps::Vector{Function} 
    agent_steps::Vector{Function}       
    post_model_steps::Vector{Function} 

    function ABMSimulation(abm::AbstractABM,properties::Dict{Symbol};
                                 example::AbstractExample=DummyExample()) 
        abmsimulation = new(abm,properties,[errorstep],[errorstep],[errorstep])
        setup!(abmsimulation,example)
        abmsimulation 
    end

    ABMSimulation(createABM::Function,properties::Dict{Symbol};
                        example::AbstractExample=DummyExample()) = 
                            ABMSimulation(createABM(),properties,example=example)

end 

