"""
    A concept for multi ABMs for orchestering a set of 
        elemantary ABMs.

    This file is included in the module SocialABMs. 
""" 

export MultiABM 

abstract type AbstractMABM  end   # <: AbstractSocialABM (to think about it)

dummyinit(mabm::AbstractMABM) = nothing 

"A MultiABM concept" 
mutable struct MultiABM   <: AbstractMABM 
    abms::Array{AbstractSocialABM,1} 

    "Dictionary of model properties"
    properties::Dict{Symbol}

    """
    Cor expecting a declaration function that declares 
        a list of elemantary ABMs together with
        MABM-level properties  
    """  
    function MultiABM(properties::Dict{Symbol} = Dict{Symbol,Any}(); 
                    initialize::Function = dummyinit,  
                    declare::Function) 
        mabm = new(declare(properties),copy(properties))
        initialize(mabm) 
        mabm
    end 

end # MultiABM  



