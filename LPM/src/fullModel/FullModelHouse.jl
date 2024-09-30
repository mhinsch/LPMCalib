module FullModelHouse
    

using CompositeStructs

using Utilities
using BasicHouseAM, IncomeHouseAM

export House
export occupantType

@composite mutable struct House{P, T}
    BasicHouse{P, T}...
    IncomeHouse...
end

House{P, T}(t, p) where{P, T} = House(t, p, P[], 0.0, 0.0, 0.0, 0.0, 0.0, false, -1, 0.0)

occupantType(h::House{P, T}) where {P, T} = P


end
