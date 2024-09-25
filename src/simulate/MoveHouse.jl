module MoveHouse
    
using Utilities
using BasicHouseAM
using HousingIM
using World

export findEmptyHouseInTown, findEmptyHouseInOrdAdjacentTown, 
        findEmptyHouseAnywhere, movePeopleToEmptyHouse!, movePeopleToHouse!


function selectHouse(list)
    if isempty(list)
        return nothing
    end
    rand(list)
end


findEmptyHouseInTown(town) = selectHouse(emptyHousesInTown(town))

function findEmptyHouseInOrdAdjacentTown(town, allHouses, allTowns) 
    adjTowns = [town; adjacent8Towns(town)]
    emptyHouses = [ house for t in adjTowns for house in emptyHousesInTown(t) ]
    selectHouse(emptyHouses)
end

# we might want to cache a list of empty houses at some point, but for now 
# this is fine
findEmptyHouseAnywhere(allHouses) = selectHouse(emptyHouses(allHouses)) 


function movePeopleToHouse!(people, house)
    # TODO 
    # - yearInTown (used in relocation cost)
    # - movedThisYear
    for person in people
        if person.pos != house
            moveToHouse!(person, house)
        end
    end
end

# people[1] determines centre of search radius
function movePeopleToEmptyHouse!(people, dmax, allHouses, allTowns=PersonTown[])
    newhouse = nothing

    if dmax == :here
        newhouse = findEmptyHouseInTown(getHomeTown(people[1]))
    end
    if dmax == :near || newhouse == nothing
        newhouse = findEmptyHouseInOrdAdjacentTown(getHomeTown(people[1]), allHouses, allTowns) 
    end
    if dmax == :far || newhouse == nothing
        newhouse = findEmptyHouseAnywhere(allHouses)
    end 
    
    if newhouse != nothing
        movePeopleToHouse!(people, newhouse)
    end
    
    newhouse
end


end
