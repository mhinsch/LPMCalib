"""
    Main simulation functions for the demographic aspect of LPM. 
""" 


module Simulate

using XAgents: Person  
using XAgents: isMale, isFemale, isSingle
using XAgents: removeOccupant!, resolvePartnership!

using MultiAgents: ABM, allagents

using MALPM.Create: LPMUKDemographyOpt

import LPM.Demography.Simulate: doDeaths!

export doDeaths!


function doDeaths!(population::ABM{Person};
                   verbose = true, sleeptime=0) 

    pars = population.properties 
    data = population.data

    people = allagents(population)

    livingPeople = typeof(pars[:example]) == LPMUKDemographyOpt ? 
        people : [person for person in people if person.info.alive]

    @assert length(livingPeople) > 0 ? 
        typeof(livingPeople[1].info.age) == Rational{Int64} :
        true  # Assumption

    (numberDeaths) = doDeaths!(people=livingPeople,parameters=pars,data=data,verbose=verbose,sleeptime=sleeptime) 

    false ? population.variables[:numberDeaths] += numberDeaths : nothing # Temporarily this way till realized 

end # function doDeaths!



end # Simulate 


#= 
function doDeaths!(population::ABM{Person};
                   verbose = true, sleeptime=0) 

    parameters = population.properties 

    (curryear,currmonth) = date2yearsmonths(Rational(parameters[:currstep]))
    currmonth = currmonth + 1 

    people = allagents(population)

    livingPeople = typeof(parameters[:example]) == LPMUKDemographyOpt ? 
        people : [person for person in people if person.info.alive]

    @assert length(livingPeople) > 0 ? 
        typeof(livingPeople[1].info.age) == Rational{Int64} :
        true  # Assumption

    for person in livingPeople

        @assert isMale(person) || isFemale(person) # Assumption 
        age = person.info.age 
        dieProb = 0
        lifeExpectancy = 0  # From the code but does not play and rule?

        if curryear >= 1950 

           age = age > 109 ? Rational(109) : person.info.age 
           ageindex = trunc(Int,age)
           rawRate = isMale(person) ? population.data[:death_male][ageindex+1,curryear-1950+1] : 
                                      population.data[:death_female][ageindex+1,curryear-1950+1]
           
           lifeExpectancy = max(90 - age, 3 // 1)  ## ??? 
           
        else # curryear < 1950 / made-up probabilities 

            babyDieProb = age < 1 ? parameters[:babyDieProb] : 0.0 
            ageDieProb  = isMale(person) ? 
                            exp(age / parameters[:maleAgeScaling])  * parameters[:maleAgeDieProb] : 
                            exp(age / parameters[:femaleAgeScaling]) * parameters[:femaleAgeDieProb]
            rawRate = parameters[:baseDieProb] + babyDieProb + ageDieProb
            
            lifeExpectancy = max(90 - age, 5 // 1)  ## ??? 

        end # currYear < 1950 

        #=
        Not realized yet 
        classPop = [x for x in self.pop.livingPeople 
                      if x.careNeedLevel == person.careNeedLevel]
        Classes to be considered in a different module 
        =#

        dieProb =  deathProbability(rawRate,person,parameters)

        #=
        The following is uncommented code in the original code < 1950
        #### Temporarily by-passing the effect of unmet care need   ######
        # dieProb = self.deathProb_UCN(rawRate, person.parentsClassRank, person.careNeedLevel, person.averageShareUnmetNeed, classPop)
        =# 

        if rand() < dieProb && rand(1:12) == currmonth && person.info.alive 
            if verbose 
                y, m = date2yearsmonths(age)
                println("person $(person.id) died year $(curryear) with age of $y")
                sleep(sleeptime) 
            end
            person.info.alive = false 
            # person.deadYear = self.year  # to be moved to agent_step!
            # deaths[person.classRank] += 1
            false ? population.variables[:numberDeaths] += 1 : nothing # Temporarily this way till realized 
            removeOccupant!(person.pos,person)
            isSingle(person) ?
                nothing :  
                resolvePartnership!(person.kinship.partner,person)
         end # rand

    end # for livingPeople
    
    if verbose
        println("number of living people : $(length(livingPeople)) from $(length(people))") 
        sleep(sleeptime)
    end 

end # function doDeaths!
=#