module Age


using ChangeEvents

using MaternityAM, KinshipAM

export selectAgeTransition, ageTransition!  
export ChangeAge1Yr


selectAgeTransition(person, pars) = true


struct ChangeAge1Yr end


function changeAge!(person, newAge, model, pars)
    person.age = newAge
    
    # NOTE: we assume all age transitions happen at whole numbers of years
    if ! isinteger(person.age)
        return
    end
    
    trigger!(ChangeAge1Yr(), person, model, pars)
    nothing
end


"Update age, maternity status and independence."
function ageTransition!(person, time, model, pars)
    if isInMaternity(person)
        # count maternity months
        stepMaternity!(person)

        # end of maternity leave
        if maternityDuration(person) >= pars.maternityLeaveDuration
            endMaternity!(person)
        end
    end 
    
    changeAge!(person, person.age + 1//12, model, pars)
    
    if !isSingle(person)
        person.pTime += 1//12
    end
end


end
