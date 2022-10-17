using Memoization

export adjacent4Towns, findHousesInTown, emptyHouses, emptyHousesInTown

# memoization not really necessary for low number of towns, but why not
"Find all towns adjacent to `town` (von Neumann neighbourhood). Memoized for efficiency - empty cache when topology changes."
@memoize adjacent4Towns(town, towns) = [ t for t in towns if isAdjacent4(town, t) ] 


"Find all houses belonging to a specific town. Memoization should make this really fast after a few iterations. Empty cache only when houses appear/disappear."
@memoize findHousesInTown(town, allHouses) = 
    [ house for house in allHouses if town(house) == town ]


emptyHouses(allHouses)  = [ house for house in allHouses if empty(house) ]

emptyHousesInTown(town, allHouses) = 
    [ house for house in findHousesInTown(town, allHouses) if empty(house) ]

