"""
A type specifying special functionalities for elemantary Social ABMs, 
    i.e. stuffs that don't exist in Agents.jl  
"""

"Social ABM to be enhanced with relevant functionlities"
abstract type AbstractSocialABM <: AbstractABM end 


"add a symbol property to a model"
function addproperty!(model::AbstractSocialABM,property::Symbol,val)
    if property in keys(model.properties)
        error("$(property) is already available")
    end 
    model.properties[property] = val  
end 
