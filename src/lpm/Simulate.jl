"""
    Main simulation functions for the demographic aspect of LPM. 
""" 


module Simulate

using Utilities: age2yearsmonths

function doDeaths!(population::SocialABM{Person}) # agent_step / model_step? 

    (curryear,currmonth) = age2yearsmonths(demography.properties[:currstep])
    currmonth = currmonth + 1 

    people = allagents(population)
    livingPeople = [person for person in people if person.info.alive]

    @assert typeof(person.info.age) == Rational 

    for person in livingPeople

        if curryear >= 1950 

            person.info.age = person.info.age > 109 ? Rational(109) : nothing 
           # rawRate = isMale(person)   ?  
           # rawRate = isFemale(person) ? 

        else # curryear < 1950 

        end
        
    end # for livingPeople 
end

end # Simulate 