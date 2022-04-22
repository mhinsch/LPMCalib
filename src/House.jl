"""
Specification of a House Agent Type. This file is included in the module AgentTypes
Type House to extend from AbstractAgent.
""" 

export  House 


mutable struct House <: AbstractAgent
    id::Int
    pos         # could be a tuble of Town, location in town
    size 
    # .... 
end 

"Constructor with named arguments"
House(id,pos;size) = House(id,pos,size)




#= 
Alternative approach 
"""
   HouseData: Data fields specifying an Agent of type House 
"""
struct HouseData <: DataSpec
    # size
    # ... 
end 

"House Agent" 
const House  = Agent{HouseData} 
=# 
