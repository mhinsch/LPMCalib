
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
    adjTowns = adjacent4Towns(town, allTowns)
    emptyHouses = [ house for town in adjTowns for house in town if empty(house) ]
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
        moveToHouse!(person, newhouse)
    end
end


function movePeopleToEmptyHouse!(people, dmax, allHouses, allTowns=Town[]) 
    newhouse = nothing

    if dmax == :here
        newhouse = findEmptyHouseInTown(house(person),allHouses)
    end
    if dmax == :near || newhouse == nothing 
        newhouse = findEmptyHouseInOrdAdjacentTown(house(person),allHouses,allTowns) 
    end
    if dmax == :far || newhouse == nothing
        newhouse = findEmptyHouseAnywhere(allHouses)
    else
        error("dmax should have any of the values :here, :near or :far")
    end 

    if newHouse != nothing
        movePeopleToHouse!(people, newHouse)
        return newHouse
    end
    nothing 
end
