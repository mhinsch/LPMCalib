"""
    Definition of a multi ABM simulation based on MultiABM concept/ 

        This file is part of  SocialSimulations module 
"""

using SocialABMs: MABMSimulation  


mutable struct MABMSimulation 

    model::AbstractMABM 
    properties::Dict{Symbol,Any}    # Simualtion propoerties    
    
    #pre_model_step::Function
    # agent_step::Function
    #model_step::Function 
    
    # Cors 

end # MABMSimulation 
