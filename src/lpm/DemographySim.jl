"""
    Main simulation functions for the demographic aspect of LPM. 
""" 


module DemographySim

using Utilities: age2yearsmonths

function doDeaths!(population::SocialABM{Person}) # agent_step / model_step? 

    (curryear,currmonth) = age2yearsmonths(demography.properties[:currstep])
    currmonth = currmonth + 1

    livingPeople = nothing  

    for person in livingPeople

        if curryear >= 1950 

        else # curryear < 1950 

        end
        
    end # for livingPeople 
end

end # DemographySim