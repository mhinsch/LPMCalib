export  House, HouseLocation

export getHomeTown, getHouseLocation, undefined, isEmpty, town 

using Utilities

include("agents_modules/carehouse.jl")


const HouseLocation  = NTuple{2,Int}


mutable struct House{P, T} 
    town :: T
    pos :: HouseLocation     # location in the town    
    # size::String                     # TODO enumeration type / at the moment not yet necessary  
    occupants::Vector{P}                           
    
    care :: CareHouse
end # House 

House{P, T}(t, p) where{P, T} = House(t, p, P[], CareHouse(0))


@delegate_onefield House care [addCareSupply!, removeCareSupply!]
@export_forward House care [netCareSupply]


undefined(house) = house.town == undefinedTown && house.pos == (-1,-1)

isEmpty(house) = length(house.occupants) == 0

town(house) = house.town 

# to replace the functions below in order to unify style across agents APIs
"town associated with house"
function getHomeTown(house)
    house.town
end

"town name associated with house"
function getHomeTownName(house)
    house.town.name
end

"house location in the associated town"
function getHouseLocation(house)
    house.pos
end

"add an occupant to a house"
function addOccupant!(house, person)
	push!(house.occupants, person) 
	nothing
end

"remove an occupant from a house"
function removeOccupant!(house, person)
    removefirst!(house.occupants, person) 
	# we can't assume anything about the layout of typeof(person)
	#person.pos = undefinedHouse 
    nothing 
end

"Costum print function for agents"
function Base.show(io::IO, house::House) 
    townName = getHomeTownName(house)
    print("House $(house.id) @ town $(townName) @ $(house.pos)")
    length(house.occupants) == 0 ? nothing : print(" occupants: ") 
    for person in house.occupants
        print(" $(person.id) ")
    end
    println() 
end 
