using TypedDelegation

using DeclUtils


export CareHouse, addCareSupply!, removeCareSupply!


mutable struct CareHouse
    netCareSupply :: Int
end

function addCareSupply!(house::CareHouse, care)
    house.netCareSupply += care
end

function removeCareSupply!(house::CareHouse, care)
    house.netCareSupply -= care
end
