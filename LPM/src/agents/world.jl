using TypedMemo

export adjacent8Towns, findHousesInTown, emptyHouses, emptyHousesInTown

# memoization not really necessary for low number of towns, but why not
#"Find all towns adjacent to `town` (von Neumann neighbourhood). Memoized for efficiency - empty cache when topology changes."
@cached adjacent8Towns(town, towns) = [ t for t in towns if isAdjacent8(town, t) ] 


#"Find all houses belonging to a specific town. Memoization should make this really fast after a few iterations. Empty cache only when houses appear/disappear."
@cached findHousesInTown(t, allHouses) = 
    [ house for house in allHouses if town(house) == t ]


emptyHouses(allHouses)  = [ house for house in allHouses if isEmpty(house) ]

emptyHousesInTown(town, allHouses) = 
    [ house for house in findHousesInTown(town, allHouses) if isEmpty(house) ]

