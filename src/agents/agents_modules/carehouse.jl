using TypedDelegation

using DeclUtils


export CareHouse, careBalance


mutable struct CareHouse{H}
    "net care this house produces (or demands for values < 0)"
    netCareSupply :: Int
    "net care this house exports to others (or receives for values < 0)"
    careProvided :: Int
    careConnections :: Vector{H}
end

CareHouse{H}() where{H} = CareHouse(0, 0, H[])

function provideCare!(house::CareHouse, care, to)
    house.careProvided += care
    push!(house.careConnections, to) 
    sort!(house.careConnections, by=objectid)
    unique!(house.careConnections)
end

function receiveCare!(house::CareHouse, care, from)
    house.careProvided -= care
    push!(house.careConnections, from)
    sort!(house.careConnections, by=objectid)
    unique!(house.careConnections)
end

function resetCare!(house::CareHouse, ncs)
    house.netCareSupply = ncs
    house.careProvided = 0
    empty!(house.careConnections)
end

careBalance(house::CareHouse) = house.netCareSupply - house.careProvided
