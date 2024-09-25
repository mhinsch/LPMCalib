using Utilities
using DeclUtils
using CompositeStructs


#include("agent_modules/carehouse.jl")




mutable struct House{P, T} 
    # size::String                     # TODO enumeration type / at the moment not yet necessary  
    
    # manual composition for now, @composite does not allow
    # partial specialisation
    
#=    "net care this house produces (or demands for values < 0)"
    netCareSupply :: Int
    "net care this house exports to others (or receives for values < 0)"
    careProvided :: Int
    careConnections :: Vector{House{P, T}}
=#    
end # House 







"Costum print function for agents"
function Base.show(io::IO, house::House) 
    townName = getHomeTownName(house)
    print("House $(house.id) @ town $(townName) @ $(house.pos)")
    length(house.occupants) == 0 ? nothing : print(" occupants: ") 
    for person in house.occupants
        print(" $(person.id) ")
    end
    println() 
end 


function Utilities.dump_header(io, h::House, FS)
    print(io, "id", FS, "pos", FS)
    Utilities.dump_header(io, h.care, FS); print(io, FS)
end

function Utilities.dump(io, house::House, FS="\t", ES=",")
    print(io, objectid(house), FS)
    Utilities.dump_property(io, house.pos, FS, ES); print(io, FS)
    # no need to dump inhabitants as well, they link back anyway
    Utilities.dump(io, house.care, FS, ES); print(io, FS)
end

