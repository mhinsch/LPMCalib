"""
A type specifying special functionalities for elemantary Social ABMs, 
    i.e. stuffs that don't exist in Agents.jl  
"""

export AbstractSocialABM
export setproperty!

"Social ABM to be enhanced with relevant functionlities"
abstract type AbstractSocialABM <: AbstractABM end 


"set a symbol property to a model"
function setproperty!(model::AbstractSocialABM,property::Symbol,val)
    if property in keys(model.properties)
        error("$(property) is already available")
    end 
    model.properties[property] = val  
end 


#=
It is thinkable to associate further attributes to SocialABMs s.a.

variable(sabm::AbstractSocialABM,var::Symbol) = sabm.variable[var]
parameter(sabm::AbstractSocialABM,par::Parameter) = sabm.parameter[par]
data(sabm::AbstractSocialABM,symbol::Symbol)  = sabm.data[symbol]
... 
function addData!(sabm,symbol,csvfile) end
function addVariable!(sabm,symbol) end 
function deleteVariable!(sabm,symbol) end

=# 