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
    
    care :: CareHouse{House{P, T}}
end # House 

House{P, T}(t, p) where{P, T} = House(t, p, P[], CareHouse{House{P, T}}())


@delegate_onefield House care [provideCare!, receiveCare!, resetCare!, careBalance]
@export_forward House care [netCareSupply, careProvided, careConnections]


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


function Utilities.dump_header(io, h::House, FS)
    print(io, "id", FS, "pos", FS)
    Utilities.dump_header(io, h.care, FS); print(io, FS)
end

function Utilities.dump(io, house::House, FS="\t", ES=",")
    print(io, objectid(house), FS)
    Utilities.dump_property(io, house.pos, FS, ES); print(io, FS)
    # no need to dump inhabitants as well, they link back anyway
    Utilities.dump(io, house.care, FS, ES); print(io, FS)
end
