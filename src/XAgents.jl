"""
Module for defining a supertype, AbstractAgent for all Agent types 
    with additional ready-to-use agents to be used in (Multi-)ABMs models 
"""
module XAgents

    using MultiAgents: AbstractAgent, AbstractXAgent, getIDCOUNTER

    include("./agents/town.jl")
    include("./agents/house.jl")
    include("./agents/person.jl")
    
end  # XAgents 

