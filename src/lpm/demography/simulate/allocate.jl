
#= 
An initial design for findNewHouse*(*) interfaces (subject to incremental 
    modification, simplifcation and tuning)
=# 

using Memoization

using XAgents

export findEmptyHouseInTown, findEmptyHouseInOrdAdjacentTown, 
        findEmptyHouseAnywhere, movePeopleToEmptyHouse!, movePeopleToHouse!


function selectHouse(list)
    if isempty(list)
        return nothing
    end
    rand(list)
end


findEmptyHouseInTown(town, allHouses) = selectHouse(emptyHousesInTown(town, allHouses))


function findEmptyHouseInOrdAdjacentTown(town, allHouses, allTowns) 
    adjTowns = adjacent8Towns(town, allTowns)
    emptyHouses = [ house for town in adjTowns 
                   for house in findHousesInTown(town, allHouses) if isEmpty(house) ]
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
function movePeopleToEmptyHouse!(people, dmax, allHouses, allTowns=Town[]) 
    newhouse = nothing

    if dmax == :here
        newhouse = findEmptyHouseInTown(people[1].pos,allHouses)
    end
    if dmax == :near || newhouse == nothing 
        newhouse = findEmptyHouseInOrdAdjacentTown(people[1].pos,allHouses,allTowns) 
    end
    if dmax == :far || newhouse == nothing
        newhouse = findEmptyHouseAnywhere(allHouses)
    end 

    if newhouse != nothing
        movePeopleToHouse!(people, newhouse)
        return newhouse
    end
    nothing 
end
