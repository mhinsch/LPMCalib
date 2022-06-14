"""
Module for specifying a type for agent-based models with some examples
"""
module SocialABMs 
    import SocialAgents: AbstractAgent      

    include("./abms/AbstractABM.jl")      # could be replaced by Agents.ABM / require more hacks  
    include("./abms/AbstractSocialABM.jl")

    include("./abms/MultiABM.jl")
    
    include("./abms/SocialABM.jl")        
    include("./abms/Population.jl") 
end # Social ABMs
