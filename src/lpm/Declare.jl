module Declare


using Global: Gender, unknown, female, male
using SocialAgents: Town, House, Person, undefinedHouse, setPartner! 
using SocialABMs: SocialABM
using Utilities:(-)

export createUKDemography

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


function createUKPopulation(properties) 

    population = Person[] 

    for i in 1 : properties[:initialPop]
        ageMale = rand((properties[:minStartAge]:properties[:maxStartAge]))
        ageFemale = ageMale - rand((-2:5))

        ageFemale = ageFemale < 24 ? 24 : ageFemale 

        # From the old code: 
        #    the following is direct translation but it does not ok 
        #    birthYear = properties[:startYear] - rand((properties[:minStartAge]:properties[:maxStartAge]))
        #    why not 
        #    birthYear = properties[:startYear]  - ageMale/Female 
        #    birthMonth = rand((1:12))

        newMan = Person(undefinedHouse,ageMale,gender=male)
        newWoman = Person(undefinedHouse,ageFemale,gender=female)   
        setPartner!(newMan,newWoman) 
        
        push!(population,newMan);  push!(population,newWoman) 

    end # for 

    population

end # createUKPopulation 


"create UK demography"
function createUKDemography(properties) 
    #TODO distribute properties among ambs and MABM  
    mapProperties = [:townGridDimension,:mapGridXDimension,:mapGridYDimension,:ukMap] - properties
    ukTowns  = SocialABM{Town}(mapProperties,
                               declare=createUKTowns) # TODO delevir only the requird properties and substract them 
    
    ukHouses = SocialABM{House}() # (declare = dict::Dict{Symbol} -> House[])              
    
    populationProperties = [:initialPop,:minStartAge,:maxStartAge] - properties 
    # Consider an argument for data 
    ukPopulation = SocialABM{Person}(populationProperties, declare=createUKPopulation)

    [ukTowns,ukHouses,ukPopulation]
end 



end # Declare 