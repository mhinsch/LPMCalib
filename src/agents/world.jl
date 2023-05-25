using Memoization

export adjacent8Towns, findHousesInTown, emptyHouses, emptyHousesInTown

"Find all towns adjacent to `town` (von Neumann neighbourhood)."
adjacent8Towns(town) = town.adjacent

"Find all houses belonging to a specific town."
findHousesInTown(t) = t.houses

emptyHouses(allHouses)  = [ house for house in allHouses if isEmpty(house) ]

emptyHousesInTown(town) = 
    [ house for house in findHousesInTown(town) if isEmpty(house) ]
