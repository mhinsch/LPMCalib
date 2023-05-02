using TypedDelegation

using DeclUtils


export CareHouse, careBalance


mutable struct CareHouse
    "net care this house produces (or demands for values < 0)"
    netCareSupply :: Int
    "net care this house exports to others (or receives for values < 0)"
    careProvided :: Int
end

CareHouse() = CareHouse(0, 0)

function provideCare!(house::CareHouse, care)
    house.careProvided += care
end

function receiveCare!(house::CareHouse, care)
    house.careProvided -= care
end

function resetCare!(house::CareHouse, ncs)
    house.netCareSupply = ncs
    house.careProvided = 0
end

careBalance(house::CareHouse) = house.netCareSupply - house.careProvided
