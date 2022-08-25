module Initialize

using  XAgents:  Person, PersonHouse, Town
using  LPM.Demography.Initialize: initializeHousesInTowns,
                                  assignCouplesToHouses!

using  MultiAgents: ABM, MultiABM 
using  MultiAgents: add_agent!, allagents

import MultiAgents: initial_connect!

export initializeDemography!

"initialize an abm of houses through an abm of towns"
function initial_connect!(abmhouses::ABM{PersonHouse},abmtowns::ABM{Town},pars) 
    towns = allagents(abmtowns)  
    houses = initializeHousesInTowns(towns,pars) 

    for house in houses 
        add_agent!(house,abmhouses)
    end
    
    nothing 
end # initial_connect! houses with towns 

# Connection is symmetric 
#initial_connect!(abmtowns::ABM{Town},abmhouses::ABM{PersonHouse},pars) = initial_connect!(abmhouses,abmtowns,pars)


""" 
    a set of houses are chosen randomly and assigned to couples 
"""
function initial_connect!(abmpopulation::ABM{Person},abmhouses::ABM{PersonHouse},pars) 
    
    population = allagents(abmpopulation) 
    houses     = allagents(abmhouses) 

    assignCouplesToHouses!(population,houses)

end  # initial_connect assign population to houses 


"Establish town houses and assign population to them"
function  initializeDemography!(demography::MultiABM)
    
    ukTowns  = demography.abms[1]
    ukHouses = demography.abms[2]
    ukPopulation = demography.abms[3] 

    initial_connect!(ukHouses,ukTowns,demography.properties.mappars)
    initial_connect!(ukPopulation,ukHouses,nothing)

end 

end # Initialize
