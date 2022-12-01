"""
Module for defining a supertype, AbstractAgent for all Agent types 
    with additional ready-to-use agents to be used in (Multi-)ABMs models 
"""
module XAgents
    export AbstractAgent, AbstractXAgent, getIDCOUNTER


    abstract type AbstractAgent
    end

    abstract type AbstractXAgent
    end

    getIDCOUNTER() = 0
end  # XAgents 

