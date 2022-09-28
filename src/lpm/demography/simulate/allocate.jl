
#= 
An initial design for findNewHouse*(*) interfaces (subject to incremental 
    modification, simplifcation and tuning)
=# 

export findEmptyHouseInTown, findEmptyHouseInOrdAdjacentTown

# internal function / subject to merge in the following functiomn 
function fineNewHouseInSelectedTowns(person,attachedPeople,selectedEmptyHouses,parameters,data,time) 
    # an unoccupied house is randomly selected out of the set empty houses in selectedTowns                     
end  

# Interneal function could be moved to src/agents/house/town.jl 
function emptyHouses(townsList) end 

# Internal function 
findEmptyHouse(person,attachedPeople,selectedTowns,parameters,data,time) = 
    fineNewHouseInSelectedTowns(person,attachedPeople,emptyHouses(selectedTowns),parameters,data,time) 

# descriptive interfaces to be exported  
findEmptyHouseInTown(person,attachedPeople,parameters,data,time;
                        verbose=true,sleeptime=0.0,checkassumption=true) = 
    findEmptyHouse(person,attachedPeople,[town(person)],parameters,data,time)


# Internal function / could be moved to a relevant source file
function adjacentTowns(town) end 

# exported interface
findEmptyHouseInOrdAdjacentTown(person,attachedPeople,parameters,data,time;
                                    verbose=true,sleeptime=0.0,checkassumption=true) = 
    findEmptyHouse(person,attachedPeople,[town(person), adjacentTowns(town(person))],parameters,data,time)

# Internal function / could be moved to a relevant source file
function allTowns(townsmap) end 

findEmptyHouseAnyWhere(person,attachedPeople,townsmap,parameters,data,time;
                    verbose=true,sleeptime=0.0,checkassumption=true) = 
    findEmptyHouse(person,attachedPeople,allTowns(townsmap), parameters,data,time,0)