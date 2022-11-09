module Initialize

using Distributions: Normal
using Random:  shuffle 
using XAgents 

export initializeHousesInTowns, assignCouplesToHouses!, initClass!, initWork!

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


"Randomly assign a population of couples to non-inhebted set of houses"
function assignCouplesToHouses!(population::Array{Person}, houses::Array{PersonHouse})
    women = [ person for person in population if isFemale(person) ]

    randomhouses = shuffle(houses)

    for woman in women
        house = pop!(randomhouses) 
        
        moveToHouse!(woman, house) 
        if !isSingle(woman)
            moveToHouse!(partner(woman), house)
        end

        for child in dependents(woman)
            moveToHouse!(child, house)
        end
    end # for person     

    for person in population
        if person.pos == undefinedHouse
            @assert isMale(person)
            @assert length(randomhouses) >= 1
            moveToHouse!(person, pop!(randomhouses))
        end
    end
end  # function assignCouplesToHouses 


function initClass!(person, pars)
    p = rand()
    class = findfirst(x->p<x, pars.cumProbClasses)-1
    classRank!(person, class)

    nothing
end


function initWork!(person, pars)
    class = classRank(person)+1
    workingTime = 0
    for i in age(person):pars.workingAge[class]
        workingTime *= pars.workDiscountingTime
        workingTime += 1
    end

    dKi = rand(Normal(0, pars.wageVar))
    initialWage = pars.incomeInitialLevels[class] * exp(dKi)
    dKf = rand(Normal(dKi, pars.wageVar))
    finalWage = pars.incomeFinalLevels[class] * exp(dKf)

    initialIncome!(person, initialWage)
    finalIncome!(person, finalWage)

    c = log(initialWage/finalWage)
    wage!(person, finalWage * exp(c * exp(-pars.incomeGrowthRate[class]*workingTime)))
    income!(person, wage(person) * pars.weeklyHours[class])
    potentialIncome!(person, income(person))
    jobTenure!(person, rand(1:50))
#    workExperience = workingTime

    nothing
end



end # module Initalize 
