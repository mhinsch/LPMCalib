"""
    create UK towns and houses. 

    This source file is included in the model LPMABMs.jl 
"""

# adjustedDensity = density * densityModifier

# future candidate 
# createUKTowns(variables,parameters,properties)

export createUKDemography # createUKTowns, createUKHouses 

import SocialAgents: Town, House  

import SocialABMs: SocialABM, add_agent!, allagents

function createUKTowns(properties) 

    uktowns = Town[] 
    
    for y in 1:properties[:mapGridYDimension]
        for x in 1:properties[:mapGridXDimension] 
            town = Town((x,y),density=properties[:ukMap][y,x])
            push!(uktowns,town)
        end
    end

    uktowns
end 

function createUKHouses(properties) 

    ukhouses = House[]

end 


function createUKDemography(properties) 

    #TODO distribute properties among ambs and MABM  

    ukTowns  = SocialABM{Town}(createUKTowns,properties) # TODO delevir only the requird properties and substract them 
    ukHouses = SocialABM{House}()              
    # ukPopulation = createUKPopulation(properties)

    # create houses within towns 
    towns = allagents(ukTowns) 
    for town in towns
        if town.density > 0 
            adjustedDensity = town.density * properties[:mapDensityModifier]

            for hx in 1:ukTowns.properties[:townGridDimension]  # TODO employ getproperty
                for hy in 1:ukTowns.properties[:townGridDimension] 

                    if(rand() < adjustedDensity)
                        house = House(town,(hx,hy))
                        add_agent!(house,ukHouses)
                    end

                end # for hy 
            end # for hx 
        end # if town.density 
    end # for town 

    (ukTowns,ukHouses)
end 

    #=

    self.x = tx
    self.y = ty
    self.houses = []
    self.name = str(tx) + "-" + str(ty)
    self.LHA = [lha1, lha2, lha3, lha4]
    self.id = Town.counter
    Town.counter += 1
    if density > 0.0:
        adjustedDensity = density * densityModifier
        for hy in range(int(townGridDimension)):
            for hx in range(int(townGridDimension)):
                if random.random() < adjustedDensity:
                    newHouse = House(self,cdfHouseClasses,
                                     classBias,hx,hy)
                    self.houses.append(newHouse)

    =# 
