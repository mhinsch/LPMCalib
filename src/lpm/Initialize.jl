module Initialize


using  Random:  shuffle 
using  XAgents: Town, House, Person
using  XAgents: undefinedHouse, isFemale, setPartner! 

using  MultiAgents: ABM, MultiABM 
using  MultiAgents: add_agent!, allagents, nagents 

import MultiAgents: initial_connect!

export initializeDemography!

"initialize an abm of houses through an abm of towns"
function initial_connect!(abmhouses::ABM{House},abmtowns::ABM{Town},properties) 

    # create houses within towns 
    towns = allagents(abmtowns)  
    for town in towns
        if town.density > 0 
            adjustedDensity = town.density * properties[:mapDensityModifier]
    
            for hx in 1:abmtowns.properties[:townGridDimension]  
                for hy in 1:abmtowns.properties[:townGridDimension] 
    
                    if(rand() < adjustedDensity)
                        house = House(town,(hx,hy))
                        add_agent!(house,abmhouses)
                    end
    
                end # for hy 
            end # for hx 
        end # if town.density 
    end # for town 

    nothing 
end

# Connection is symmetric 
initial_connect!(abmtowns::ABM{Town},abmhouses::ABM{House},properties) = initial_connect!(abmhouses,abmtowns,properties)


""" 
    initialize an abm of houses through an abm of towns
    a set of houses are chosen randomly and assigned to couples 
"""
function initial_connect!(abmpopulation::ABM{Person},abmhouses::ABM{House},properties) 
    
    numberOfMens        = trunc(Int,nagents(abmpopulation) / 2)       # it is assumed that half of the population is men
    randomHousesIndices = shuffle(1:nagents(abmhouses))    
    randomhouses        = allagents(abmhouses)[randomHousesIndices[1:numberOfMens]] 
    population          = allagents(abmpopulation) 

    for man in population
        isFemale(man) ? continue : nothing 

        house  = pop!(randomhouses) 
        man.pos = man.kinship.partner.pos = house 

        append!(house.occupants, [man, man.kinship.partner])

    end # for person     
    
    length(randomhouses) > 0 ? error("random houses for occupation has length $(length(randomhouses)) > 0") : nothing 
end 


"Establish town houses and assign population to them"
function  initializeDemography!(demography::MultiABM)
    
    ukTowns  = demography.abms[1]
    ukHouses = demography.abms[2]
    ukPopulation = demography.abms[3] 

    initial_connect!(ukHouses,ukTowns,demography.properties)
    initial_connect!(ukPopulation,ukHouses,demography.properties)
end



end 