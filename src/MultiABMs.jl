"""
Module for specifying a type for agent-based models with some examples
"""
module MultiABMs 
    # import XAgents: AbstractAgent      

    include("./abms/AbstractABM.jl")      # could be replaced by Agents.ABM / require more hacks  

    include("./abms/MultiABM.jl")
    include("./abms/ABM.jl")     
       
    include("./abms/Population.jl") 
end # MultiABMs
