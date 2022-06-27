"""
Module for defining a supertype, AbstractAgent for all Agent types 
    with additional ready-to-use agents to be used in (Multi-)ABMs models 
"""
module XAgents

    using MultiAgents: AbstractAgent, AbstractXAgent, getIDCOUNTER

    include("./agents/AbstractPerson.jl")

    include("./agents/Town.jl")
    include("./agents/House.jl")
    include("./agents/Person.jl")
    
end  # XAgents 

