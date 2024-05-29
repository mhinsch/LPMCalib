using CompositeStructs


export  House, HouseLocation

export getHomeTown, getHouseLocation, addOccupant!, removeOccupant!, isOccupied, isEmpty, town 

using Utilities
using DeclUtils

include("agent_modules/carehouse.jl")


const HouseLocation  = NTuple{2,Int}


mutable struct House{P, T} 
    town :: T
    pos :: HouseLocation     # location in the town    
    # size::String                     # TODO enumeration type / at the moment not yet necessary  
    occupants::Vector{P}                           
    
    # manual composition for now, @composite does not allow
    # partial specialisation
    
    "net care this house produces (or demands for values < 0)"
    netCareSupply :: Int
    "net care this house exports to others (or receives for values < 0)"
    careProvided :: Int
    careConnections :: Vector{House{P, T}}
    
    householdIncome :: Float64 
    disposableIncome :: Float64
    incomePerCapita :: Float64
    cumulativeIncome :: Float64
    wealth :: Float64
    ownedByOccupants :: Bool
    incomeDecile :: Int
    ageOccupants :: Float64
end # House 

House{P, T}(t, p) where{P, T} = House(t, p, P[], 0, 0, House{P, T}[], 0.0, 0.0, 0.0, 0.0, 0.0, false, -1, 0.0)

occupantType(h::House{P, T}) where {P, T} = P


isEmpty(house) = isempty(house.occupants)
isOccupied(house) = !isempty(house.occupants) 

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
    idx = findfirst(isequal(person), house.occupants)
    @assert idx != nothing
    remove_unsorted!(house.occupants, idx)
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
