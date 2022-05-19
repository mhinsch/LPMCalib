"""
    create UK towns and houses. 

    This source file is included in the model LPMABMs.jl 
"""

# adjustedDensity = density * densityModifier

# future candidate 
# createUKTowns(variables,parameters,properties)

export createUKTowns

function createUKTowns(properties) 

    uktowns = SocialABM{Town}()

    for y in 1:properties[:gridYDimension]
        for x in 1:properties[:gridXDimension] 
            town = Town((x,y),density=properties[:ukMap][y,x])
            add_agent!(town,uktowns)
        end
    end

    uktowns
end 

#= 
self.towns = []
self.allHouses = []
self.occupiedHouses = []
ukMap = np.array(ukMap)
ukMap.resize(int(gridYDimension), int(gridXDimension))
ukClassBias = np.array(ukClassBias)
ukClassBias.resize(int(gridYDimension), int(gridXDimension))
lha1 = np.array(lha1)
lha1.resize(int(gridYDimension), int(gridXDimension))
lha2 = np.array(lha1)
lha2.resize(int(gridYDimension), int(gridXDimension))
lha3 = np.array(lha1)
lha3.resize(int(gridYDimension), int(gridXDimension))
lha4 = np.array(lha1)
lha4.resize(int(gridYDimension), int(gridXDimension))
for y in range(int(gridYDimension)):
    for x in range(int(gridXDimension)):
        newTown = Town(townGridDimension, x, y,
                       cdfHouseClasses, ukMap[y][x],
                       ukClassBias[y][x], densityModifier,
                       lha1[y][x], lha2[y][x], lha3[y][x], lha4[y][x])
        self.towns.append(newTown)
=# 

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
