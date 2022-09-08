"""

"""

module Create 

using Utilities: Gender, unknown, female, male
using XAgents: Person, Town
using XAgents: undefinedHouse, setAsPartners!

### 

function createUKTowns(pars) 

    uktowns = Town[] 
    
    for y in 1:pars.mapGridYDimension
        for x in 1:pars.mapGridXDimension 
            town = Town((x,y),density=pars.ukMap[y,x])
            push!(uktowns,town)
        end
    end

    uktowns
end

function createUKPopulation(parameters) 

    pars = parameters.poppars
    population = Person[] 

    for i in 1 : pars.initialPop
        ageMale = rand((pars.minStartAge:pars.maxStartAge))
        ageFemale = ageMale - rand((-2:5))
        ageFemale = ageFemale < 24 ? 24 : ageFemale
        
        rageMale = ageMale + rand(0:11) // 12     
        rageFemale = ageFemale + rand(0:11) // 12 

        # From the old code: 
        #    the following is direct translation but it does not ok 
        #    birthYear = properties[:startYear] - rand((properties[:minStartAge]:properties[:maxStartAge]))
        #    why not 
        #    birthYear = properties[:startYear]  - ageMale/Female 
        #    birthMonth = rand((1:12))

        newMan = Person(undefinedHouse,rageMale,gender=male)
        newWoman = Person(undefinedHouse,rageFemale,gender=female)   
        setAsPartners!(newMan,newWoman) 
        
        push!(population,newMan);  push!(population,newWoman) 

    end # for 

    population

end # createUKPopulation 


end # module Create 