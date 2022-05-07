#=
A set of spaces on which common agents and ABMs are operating 
=#

modules Spaces 

    export Map4DLocation, GridSpace 

    const Map4DLocation = NTuple{4,Int}

    struct GridSpace 
        gridDimension::NTuple{D,Int} where D  
    end 
 
    function createTownLocationType(x,y)
        GridSpace((x,y))
    end

end # Spaces 