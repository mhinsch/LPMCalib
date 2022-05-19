export Town, undefinedTown

import Spaces: TownLocation

"""
Specification of a Town agent type.

Every person in the population is an agent with a house as 
a position. Every house is an agent with assigned town as a
position. 

This file is included in the module SocialAgents 

Type Town to extend from AbstractAgent.
"""
mutable struct Town <: AbstractAgent
    id
    pos::TownLocation
    name::String                            # does not look necessary
    # lha::Array{Float64,1}                 # local house allowance 
                                            #   a vector of size 4 each corresponding the number of bed rooms 
    density::Float64                        # relative population density w.r.t. the town with the highest density 
    # houses::Array{LPMHouse,1}             # List of houses  (can be omitted to avoid circular dependence)  

    function Town(pos::TownLocation,name::String,density) 
        global IDCOUNTER = IDCOUNTER + 1 
        new(IDCOUNTER,pos,name,density)
    end 

end  # Town 

Town(pos;name="",density=0.0) = Town(pos,name,density)

const undefinedTown = Town((-1,-1),"",0.0)

#=
self.x = tx
        self.y = ty
        self.houses = []
        self.name = str(tx) + "-" + str(ty)
        self.LHA = [lha1, lha2, lha3, lha4]
        self.id = Town.counter
        Town.counter += 1
        if density > 0.0:
            adjustedDensity = density * densityModifier
            for hy in range(int(townGridDimension)):
                for hx in range(int(townGridDimension)):
                    if random.random() < adjustedDensity:
                        newHouse = House(self,cdfHouseClasses,
                                         classBias,hx,hy)
                        self.houses.append(newHouse)
=# 




 