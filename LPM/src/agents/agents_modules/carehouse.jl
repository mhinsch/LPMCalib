export provideCare!, receiveCare!, resetCare!, careBalance


struct CareHouse{H}
    "net care this house produces (or demands for values < 0)"
    netCareSupply :: Int
    "net care this house exports to others (or receives for values < 0)"
    careProvided :: Int
    careConnections :: Vector{H}
end

function provideCare!(house, care, to)
    house.careProvided += care
    if !(to in house.careConnections)
        push!(house.careConnections, to) 
    end
    #sort!(house.careConnections, by=objectid)
    #sorted_unique!(house.careConnections)
    #unique!(house.careConnections)
end

function receiveCare!(house, care, from)
    house.careProvided -= care
    if !(from in house.careConnections)
        push!(house.careConnections, from)
    end
    #sort!(house.careConnections, by=objectid)
    #sorted_unique!(house.careConnections)
    #unique!(house.careConnections)
end

function resetCare!(house, ncs)
    house.netCareSupply = ncs
    house.careProvided = 0
    empty!(house.careConnections)
end

careBalance(house) = house.netCareSupply - house.careProvided
