export  House 

export getHomeTown, getHouseLocation, setHouse!,  undefined

using Utilities: HouseLocation
using SomeUtil: removefirst!

"""
Specification of a House Agent Type. 

This file is included in the module XAgents 

Type House to extend from AbstracXAgent.
""" 

mutable struct House{P, T} <: AbstractXAgent
    id :: Int
    town :: T
    pos :: HouseLocation     # location in the town    
    # size::String                     # TODO enumeration type / at the moment not yet necessary  
    occupants::Vector{P}                           

    House{P, T}(town, pos) where {P, T} = new(getIDCOUNTER(),town, pos,P[])
end # House 


undefined(house) = house.town == undefinedTown && house.pos == (-1,-1)

"town associated with house"
function getHomeTown(house::House)
    house.town
end

"town name associated with house"
function getHomeTownName(house::House)
    house.town.name
end

"house location in the associated town"
function getHouseLocation(house::House)
    house.pos
>>>>>>> develop
end 

"add an occupant to a house"
function addOccupant!(house::House{P}, person::P) where {P}
	push!(house.occupants, person) 
	nothing
end

"remove an occupant from a house"
function removeOccupant!(house::House{P}, person::P) where {P}
    removefirst!(house.occupants, person) 
	# we can't assume anything about the layout of typeof(person)
	#person.pos = undefinedHouse 
    nothing 
end

"Costum print function for agents"
function Base.show(io::IO, house::House{P}) where P
    townName = getHomeTownName(house)
    print("House $(house.id) @ town $(townName) @ $(house.pos)")
    length(house.occupants) == 0 ? nothing : print(" occupants: ") 
    for person in house.occupants
        print(" $(person.id) ")
    end
    println() 
end 
