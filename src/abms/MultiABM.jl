#=
A concept for a multi-agent based model composed of elementary 
agent based models 
=#


"""
  A MultiABM concept 
"""
mutable struct MutliABM 

    "List of elemantary ABMs"
    abms::Vector{AbstractSocialABM}() 

    "Dictionary of model properties"
    properties::Dict{Symbol}

    """ 
      Cor expecting a declaration function that declares 
        a list of elemantary ABM together with
        MABM-level properties  
    """
    MultiABM(properties::Dict{Symbol} = Dict{Symbol,Any};
        declare::Function) = 
            new(declare(properties),copy(properties))     

end 