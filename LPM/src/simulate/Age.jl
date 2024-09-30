module Age


using ChangeEvents

using MaternityAM, KinshipAM

export selectAgeTransition, ageTransition!  
export ChangeAge1Yr


# transition filter
selectAgeTransition(person, pars) = true


# event tag
struct ChangeAge1Yr end


"Change a person's age. Emits the `ChangeAge1Yr` signal if the new age is an integer."
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
    
    # count relationship time
    # currently unused
    if !isSingle(person)
        person.pTime += 1//12
    end
end


end
