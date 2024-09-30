module BasicHouseAM
    

using Utilities


export BasicHouse, HouseLocation
export isEmpty, isOccupied, getHomeTown, getHomeTownName, getHouseLocation
export addOccupant!, removeOccupant!


const HouseLocation  = NTuple{2,Int}

struct BasicHouse{P, T}
    town :: T
    pos :: HouseLocation     # location in the town    
    occupants::Vector{P}                           
end


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

"Remove an occupant from a house. Invalidates order of occupants."
function removeOccupant!(house, person)
    idx = findfirst(isequal(person), house.occupants)
    @assert idx != nothing
    remove_unsorted!(house.occupants, idx)
    nothing 
end

end
