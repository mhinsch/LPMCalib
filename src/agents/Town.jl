export Town, undefinedTown
# export show

using Spaces: TownLocation

"""
Specification of a Town agent type.

Every person in the population is an agent with a house as 
a position. Every house is an agent with assigned town as a
position. 

This file is included in the module XAgents 

Type Town to extend from AbstractAXgent.
"""
mutable struct Town <: AbstractXAgent
    id
    pos::TownLocation
    name::String                            # does not look necessary
    # lha::Array{Float64,1}                 # local house allowance 
                                            #   a vector of size 4 each corresponding the number of bed rooms 
    density::Float64                        # relative population density w.r.t. the town with the highest density 

    ""
    function Town(pos::TownLocation,name::String,density) 
        global IDCOUNTER = IDCOUNTER + 1
        new(IDCOUNTER,pos,name,density)
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
1





 