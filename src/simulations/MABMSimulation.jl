"""
    Definition of a multi ABM simulation based on MultiABM concept/ 

        This file is part of  SocialSimulations module 
"""

using SocialABMs: AbstractMABM 
export MABMSimulation


mutable struct MABMSimulation <: AbstractMABMSimulation 

    model::AbstractMABM 
    simulations::Array{ABMSocialSimulation,1}
    properties::Dict{Symbol,Any}    # Simualtion propoerties    
    
    #mabm_step::Function 
    
    function MABM(mabm::AbstractMABM,properties::Dict{Symbol};
                example=DummyExample())
        n = length(model.abms)
        simulations = AbstractABMSimulation[] 
        for i in 1:n 
            simulations[i] = ABMSocialSimulation(model.abms[i],propoerties,example=example)
        end 
        sim = new(mabm,simulations,properties)
        setup!(sim,example)
        sim 
    end

end # MABMSimulation 



