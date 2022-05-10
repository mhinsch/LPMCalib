"""
Specification of a House Agent Type. 

This file is included in the module SocialAgents 

Type House to extend from AbstractAgent.
""" 

export  House 

export getHomeTown, getHouseLocation

import Spaces: HouseLocation
# import SocialAgents:House

mutable struct House <: AbstractAgent
    id
    pos::Tuple{Town,HouseLocation}     # town and location in the town    
    size::String 

    function House(pos,s) 
        global IDCOUNTER = IDCOUNTER + 1
        new(IDCOUNTER,pos,s)
    end 
    
end # House 

House(pos;s="") = House(pos,s)
House(town::Town,locationInTown::HouseLocation,s::String) = House((town,locationInTown),s)

const undefinedHouse = House(undefinedTown,(-1,-1),"")

"town associated with house"
function getHomeTown(house::House)
    house.pos[1]
end

"town name associated with house"
function getHomeTown(house::House)
    getProperty(house.pos[1],:name)
end

"house location in the associated town"
function getHouseLocation(house::House)
    house.pos[2]
end 

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
