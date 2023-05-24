export Town, undefinedTown, TownLocation
export isAdjacent8, adjacent8Towns, manhattanDistance


"""
Specification of a Town agent type.

Every person in the population is an agent with a house as 
a position. Every house is an agent with assigned town as a
position. 

This file is included in the module XAgents 

Type Town to extend from AbstractAXgent.
"""

const TownLocation  = NTuple{2,Int}

struct Town 
    pos::TownLocation
    # lha::Array{Float64,1}                 # local house allowance 
                                            #   a vector of size 4 each corresponding the number of bed rooms 
    density::Float64                        # relative population density w.r.t. the town with the highest density 
end  # Town 

"costum show method for Town"
function Base.show(io::IO,  town::Town) 
    print(" Town $(town.id) ")  
    print("@ $(town.pos)") 
    println(" density: $(town.density)")
end 

# Base.show(io::IO, ::MIME"text/plain", town::Town) = Base.show(io,town)
    
const undefinedTown = Town((-1,-1), 0.0)

isAdjacent8(town1, town2) = 
    abs(town1.pos[1] - town2.pos[1]) <= 1 &&   
    abs(town1.pos[2] - town2.pos[2]) <= 1 

manhattanDistance(town1, town2) = 
    abs(town1.pos[1] - town2.pos[1]) +   
    abs(town1.pos[2] - town2.pos[2]) 
