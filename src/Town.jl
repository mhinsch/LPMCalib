"""
Specification of a Town agent type.

Every person in the population is an agent with a house as 
a position. Every house is an agent with assigned town as a
position. 

This file is included in the module SocialAgents 

Type Town to extend from AbstractAgent.
"""

export Town

import Spaces: TownLocation

mutable struct Town <: AbstractAgent
    id
    pos::TownLocation
    name::String 

    function Town(pos::TownLocation,str::String) 
        global IDCOUNTER = IDCOUNTER + 1 
        new(IDCOUNTER,pos,str)
    end 

end  # Town 



