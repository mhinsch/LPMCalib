
export Town, undefinedTown, isAdjacent4, adjacent4Towns
# export show

using Utilities: TownLocation

"""
Specification of a Town agent type.

Every person in the population is an agent with a house as 
a position. Every house is an agent with assigned town as a
position. 

This file is included in the module XAgents 

Type Town to extend from AbstractAXgent.
"""
struct Town <: AbstractXAgent
    id::Int
    pos::TownLocation
    name::String                            # does not look necessary
    # lha::Array{Float64,1}                 # local house allowance 
                                            #   a vector of size 4 each corresponding the number of bed rooms 
    density::Float64                        # relative population density w.r.t. the town with the highest density 

    ""
    function Town(pos::TownLocation,name::String,density::Float64) 
        #global IDCOUNTER = IDCOUNTER + 1
        # idcounter = getIDCOUNTER() 
        # new(IDCOUNTER,pos,name,density)
        new(getIDCOUNTER(),pos,name,density)
    end 

end  # Town 

"costum show method for Town"
function Base.show(io::IO,  town::Town) 
    print(" Town $(town.id) ")  
    isempty(town.name) ? nothing : print(" $(town.name) ")
    print("@ $(town.pos)") 
    println(" density: $(town.density)")
end 

# Base.show(io::IO, ::MIME"text/plain", town::Town) = Base.show(io,town)
    
Town(pos;name="",density=0.0) = Town(pos,name,density)

const undefinedTown = Town((-1,-1),"",0.0)

isAdjacent4(town1,town2) = 
    abs(town1.pos[1] - town2.pos[1]) <= 1 &&   
    abs(town1.pos[2] - town2.pos[2]) <= 1 

