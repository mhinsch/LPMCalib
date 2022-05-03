"""
Specification of a House Agent Type. This file is included in the module SocialAgents
Type House to extend from AbstractAgent.
""" 

export  House 

mutable struct House <: AbstractAgent
    id
    pos         # could be a tuble of Town, location in map or town id
    size 

    function House(pos,s) 
        global IDCOUNTER = IDCOUNTER + 1
        new(IDCOUNTER,pos,s)
    end 
    
end # House 

House(pos;size="small") = House(pos,size)

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
