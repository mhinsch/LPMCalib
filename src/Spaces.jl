"""
    A set of spaces on which common agents 
    and ABMs are operating
""" 
module Spaces 

    export Map4DLocation, GridSpace
    export TownLocation, HouseLocation 

    const Map4DLocation = NTuple{4,Int}

    const TownLocation  = NTuple{2,Int}

    const HouseLocation  = NTuple{2,Int}

    struct GridSpace 
        gridDimension::NTuple{D,Int} where D  
    end 
 
    function createTownLocationType(x,y)
        GridSpace((x,y))
    end

end # Spaces 