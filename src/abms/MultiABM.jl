"""
    A concept for multi ABMs for orchestering a set of 
        elemantary ABMs.

    This file is included in the module SocialABMs. 
""" 

export MultiABM 

"A MultiABM concept" 
mutable struct MultiABM # <: AbstractSocialABM (to think about it)
    abms::Array{AbstractSocialABM,1} 

    "Dictionary of model properties"
    properties::Dict{Symbol}

    """
    Cor expecting a declaration function that declares 
        a list of elemantary ABMs together with
        MABM-level properties  
    """  
    MultiABM(properties::Dict{Symbol} = Dict{Symbol,Any}(); 
             declare::Function) =  new(declare(properties),copy(properties))     
end # MultiABM  

### ^^^ attach stepfunction!

