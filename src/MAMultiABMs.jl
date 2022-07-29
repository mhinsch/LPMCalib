"""
Module for specifying a type for agent-based models with some examples, MultiAgents-dependent
"""
module MAMultiABMs 
    
    using MultiAgents: AbstractAgent 

    using MultiAgents: ABM

    include("./maabms/Population.jl") 
end # MAMultiABMs
