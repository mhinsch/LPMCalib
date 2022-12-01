
export createTowns, initializeHousesInTowns


function createTowns(pars) 
    towns = Town[] 
    
    for y in 1:pars.mapGridYDimension
        for x in 1:pars.mapGridXDimension 
            town = Town((x,y),density=pars.map[y,x])
            push!(towns, town)
        end
    end

    towns
end


"initialize houses in a given set of towns"
function initializeHousesInTowns(towns::Array{Town,1}, pars) 
    houses = PersonHouse[] 

    for town in towns
        if town.density > 0

            adjustedDensity = town.density * pars.mapDensityModifier
        
            for hx in 1:pars.townGridDimension  
                for hy in 1:pars.townGridDimension 
        
                    if(rand() < adjustedDensity)
                        house = PersonHouse(town,(hx,hy))
                        push!(houses,house)
                    end
        
                end # for hy 
            end # for hx 
  
        end # if town.density 
    end # for town 
    
    houses  
end  # function initializeHousesInTwons 
