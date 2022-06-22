"""
    Main simulation functions for the demographic aspect of LPM. 
""" 


module Simulate

using SocialAgents: Person 
using SocialAgents: isMale, isFemale
using SocialABMs: SocialABM, allagents
using Utilities: age2yearsmonths
export doDeaths!

function doDeaths!(population::SocialABM{Person}) # agent_step / model_step? 

    parameters = population.properties 

    (curryear,currmonth) = age2yearsmonths(Rational(population.properties[:currstep]))
    currmonth = currmonth + 1 

    people = allagents(population)
    livingPeople = [person for person in people if person.info.alive]

    #=
    println("living people $(length(livingPeople)) sample \n : ") 
    println(livingPeople[1:10]) 
    println(livingPeople[1].info.age)
    println(typeof(livingPeople[1].info.age))
    @assert typeof(livingPeople[1].info.age) == Rational{Int64} 
    sleep(1)
    =# 

    for person in livingPeople

        @assert isMale(person) || isFemale(person) # Assumption 
        age = person.info.age 

        if curryear >= 1950 

           age = age > 109 ? Rational(109) : person.info.age 
           rawRate = isMale(person) ? population.data[:death_male] : 
                                      population.data[:death_female]
           
           error("translation incomplete for year >= 1950 ")

        else # curryear < 1950 

            babyDieProb = age < 1 ? parameters{:babyDieProb} : 0.0 
            ageDieProb  = isMale(person) ? 
                            exp(age / parameters[:maleAgeScaling])  * parameters[:maleAgeDieProb] : 
                            exp(age / parameters[:femaleAgeScaling]) * parameters[:femaleAgeDieProb]
            rawRate = parameters[:baseDieProb] + babyDieProb + ageDieProb

            #=
            Not realized yet: 
            classPop = [x for x in self.pop.livingPeople 
                              if x.careNeedLevel == person.careNeedLevel]
            =#

        end
        
    end # for livingPeople 
end

end # Simulate 