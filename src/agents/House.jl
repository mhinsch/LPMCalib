export  House 

export getHomeTown, getHouseLocation, setHouse!, removeOccupant!

using Utilities: HouseLocation
using SomeUtil: removefirst!

"""
Specification of a House Agent Type. 

This file is included in the module XAgents 

Type House to extend from AbstracXAgent.
""" 
mutable struct House <: AbstractXAgent
    id
    pos::Tuple{Town,HouseLocation}     # town and location in the town    
    # size::String                     # TODO enumeration type / at the moment not yet necessary  
    occupants::Vector{AbstractPerson}                           

    House(pos) = new(getIDCOUNTER(),pos,AbstractPerson[]) 
end # House 

House(town::Town,locationInTown::HouseLocation) = House((town,locationInTown))

const undefinedHouse = House(undefinedTown,(-1,-1))

"town associated with house"
function getHomeTown(house::House)
    house.pos[1]
end

"town name associated with house"
function getHomeTownName(house::House)
    house.pos[1].name
end

"house location in the associated town"
function getHouseLocation(house::House)
    house.pos[2]
end 

"associate a house to a person"
setHouse!(person::AbstractPerson,house::House)  = error("Not implemented")

"assoicate a house to a person"
setHouse!(house::House,person::AbstractPerson)  = setHouse!(person,house)

"remove an occupant from a house"
function removeOccupant!(house, person)
    removefirst!(house.occupants, person) 
    person.pos = undefinedHouse 
    nothing 
end

"Costum print function for agents"
function Base.show(io::IO, house::House)
    townName = getHomeTownName(house)
    print("House $(house.id) @ town $(townName) @ $(house.pos[2])")
    length(house.occupants) == 0 ? nothing : print(" occupants: ") 
    for person in house.occupants
        print(" $(person.id) ")
    end
    println() 
end 