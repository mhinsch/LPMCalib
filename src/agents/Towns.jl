module Towns


export Town, TownLocation
export isAdjacent8, manhattanDistance


"""
Specification of a Town agent type.

Every person in the population is an agent with a house as 
a position. Every house is an agent with assigned town as a
position. 
"""

const TownLocation  = NTuple{2,Int}

mutable struct Town{H} 
    pos::TownLocation
    density::Float64                        # relative population density w.r.t. the town with the highest density 
    houses :: Vector{H}
    adjacent :: Vector{Town{H}}
    # TODO should be separate module
    lha :: Vector{Float64}
end  # Town 

Town{H}(pos, density) where {H} = Town(pos, density, H[], Town{H}[], Float64[])

"costum show method for Town"
function Base.show(io::IO,  town::Town) 
    print(" Town $(town.id) ")  
    print("@ $(town.pos)") 
    println(" density: $(town.density)")
end 


isAdjacent8(town1, town2) = 
    abs(town1.pos[1] - town2.pos[1]) <= 1 &&   
    abs(town1.pos[2] - town2.pos[2]) <= 1 

manhattanDistance(town1, town2) = 
    abs(town1.pos[1] - town2.pos[1]) +   
    abs(town1.pos[2] - town2.pos[2]) 
    
    
end
