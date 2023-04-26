


socialCareDemand(person, pars) = pars.careDemandInHours[careNeedLevel(person)+1]

numCareLevels(pars) = length(pars.careDemandInHours)


function childCareNeed(child, model, pars)
    ageC = age(child)

    childCare = 
        if ageC < 1
            pars.zeroYearCare
        elseif ageC < 13
            pars.childCareDemand
        else
            0
        end
    
    socCare = socialCareDemand(child, pars)
    
    childCare = max(0, childCare - socCare)
     
    schoolHours = 
        if ageC < 3
            0 
        elseif ageC <= 5
            pars.freeChildCareHoursPreSchool
        else
            pars.freeChildCareHoursSchool
        end
     
     childCare = max(0, childCare - schoolHours)
end
     
        
function householdChildCareNeed(house, model, pars)
    maxChildCare = 0
    for person in house.occupants
        if age(person) >= 13
            continue
        end
        care = childCareNeed(person)
        maxChildCare = max(care, maxChildCare)
    end
    maxChildCare
end
 
 
function householdSocialCareNeed(house, model, pars)
    careNeed = 0
    for person in house.occupants
        careNeed += socialCareDemand(person)
    end
    
    careNeed
end
 
    function bla()
        
    
function householdSocialCareSupply(house, model, pars)
    supply = 0

end
 
