
#= 
An initial design for findNewHouse*(*) interfaces (subject to incremental 
    modification, simplifcation and tuning)
=# 

export findEmptyHouseInTown, findEmptyHouseInOrdAdjacentTown, 
        findEmptyHouseAnyWhere, allocatePeopleToNewHouse

# internal function / subject to merge in the following functiom
# an unoccupied house is randomly selected out of the set empty houses in selectedTowns 
findEmptyHouseInSelectedTowns(emptyHouses) = rand(emptyHouses)                       


# Interneal function could be moved to src/agents/house/town.jl 
emptyHouses(allHouses,townsList)  = 
    [ house for house in allHouses if town(house) in townsList ]


# Internal function 
findEmptyHouse(allHouses,selectedTowns) = 
    findEmptyHouseInSelectedTowns(emptyHouses(allHouses,selectedTowns)) 

# descriptive interfaces to be exported  
# find an empty house in the same town where a person is living 
findEmptyHouseInTown(person,allHouses) = findEmptyHouse(allHouses,[town(person)])


# Internal function / could be moved to a relevant source file
adjacentTowns(town,towns) = [ t for t in towns if isAdjacent(town) ] 

# exported interface
findEmptyHouseInOrdAdjacentTown(person, allHouses, allTowns) = 
    findEmptyHouse(allHouses, [ town(person), adjacentTowns(town(person),allTowns) ])


findEmptyHouseAnyWhere(allHouses) = 
    findEmptyHouseInSelectedTowns([ house for house in allHouses if empty(house)]) 


function allocatePeopleToNewHouse!(person,attachedPeople,allHouses,dmax,allTowns=Town[]) 

    if dmax == "here"
        newhouse = findEmptyHouseInTown(person,allHouses)
    elseif dmax == "near" 
        newhouse = findEmptyHouseInOrdAdjacentTown(person,allHouses,allTowns) 
    elseif dmax == "far"
        newhouse = findEmptyHouseAnyWhere(allHouses)
    else
        error("dmax should have any of the values here, near or far")
    end 

    setHouse!(person,newhouse)
    for someone in attachedPeople
        setHouse!(person,newhouse)
    end

    nothing 
end