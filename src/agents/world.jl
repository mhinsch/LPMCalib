using Memoization

export adjacent8Towns, findHousesInTown, emptyHouses, emptyHousesInTown

"Find all towns adjacent to `town` (von Neumann neighbourhood). Memoized for efficiency - empty cache when topology changes."
adjacent8Towns(town, towns) = town.adjacent

"Find all houses belonging to a specific town."
findHousesInTown(t) = t.houses

emptyHouses(allHouses)  = [ house for house in allHouses if isEmpty(house) ]

emptyHousesInTown(town) = 
    [ house for house in findHousesInTown(town) if isEmpty(house) ]
