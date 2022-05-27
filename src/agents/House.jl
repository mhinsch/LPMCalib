export  House 

export getHomeTown, getHouseLocation

import Spaces: HouseLocation



"""
Specification of a House Agent Type. 

This file is included in the module SocialAgents 

Type House to extend from AbstractAgent.
""" 
mutable struct House <: AbstractAgent
    id
    pos::Tuple{Town,HouseLocation}     # town and location in the town    
    # size::String                       # TODO enumeration type / at the moment not yet necessary  
    # occupants                          # cannot be static due to circular dependencies ::Vector{Person}
                                        # Is this actually needed? 

    function House(pos)#s;occupants=[]) 
        global IDCOUNTER = IDCOUNTER + 1
        new(IDCOUNTER,pos)#,occupants)
    end 
    
end # House 

#=
House(pos;size="",occupants=[]) = House(pos,size)
House(town::Town,locationInTown::HouseLocation;size="",occupants=[]) = House((town,locationInTown),size,occupants=[])
=# 
House(town::Town,locationInTown::HouseLocation) = House((town,locationInTown))

const undefinedHouse = House(undefinedTown,(-1,-1))

"town associated with house"
function getHomeTown(house::House)
    house.pos[1]
end

"town name associated with house"
function getHomeTownName(house::House)
    getProperty(house.pos[1],:name)
end

"house location in the associated town"
function getHouseLocation(house::House)
    house.pos[2]
end 
