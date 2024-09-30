module World
    
using BasicHouseAM

export adjacent8Towns, findHousesInTown, emptyHouses, emptyHousesInTown

"Find all towns adjacent to `town` (von Neumann neighbourhood)."
adjacent8Towns(town) = town.adjacent

"Find all houses belonging to a specific town."
findHousesInTown(t) = t.houses

function emptyHouses(allHouses)
    ret = similar(allHouses, 0)
    for house in allHouses 
        if isEmpty(house)
            push!(ret, house)
        end
    end
    ret
end

emptyHousesInTown(town) = emptyHouses(findHousesInTown(town))
    
    
end
