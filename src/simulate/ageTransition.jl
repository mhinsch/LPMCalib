using Distributions

export selectAgeTransition, ageTransition!, selectWorkTransition, workTransition!


selectAgeTransition(person, pars) = true


function changeStatus!(person, newStatus, model, pars)
    person.status = newStatus
    careSupplyChanged!(person, pars)
    
    if student(person)
        person.classRank = 0
    elseif retired(person)
        setEmptyJobSchedule!(person)
        person.wage = 0

        shareWorkingTime = person.workingPeriods / pars.minContributionPeriods

        dK = rand(Normal(0, pars.wageVar))
        person.pension = person.lastIncome * shareWorkingTime * exp(dK)
    end
end


function changeAge!(person, newAge, model, pars)
    person.age = newAge
    
    # NOTE: we assume all age transitions happen at whole numbers of years
    if ! isinteger(person.age)
        return
    end
    
    # child ages out of care need this time step
    if person.age == pars.stopBabyCareAge || person.age == pars.stopChildCareAge 
        careNeedChanged!(person, pars)
    end

    if person.age == pars.ageIndependence
        # also updates guardian
        setAsIndependent!(person)
    end
    
    if person.age == pars.ageTeenagers
        changeStatus!(person, WorkStatus.teenager, model, pars)
    # all agents first become students, start working in social transition
    elseif person.age == pars.ageOfAdulthood
        changeStatus!(person, WorkStatus.student, model, pars)
    elseif person.age == pars.ageOfRetirement
        changeStatus!(person, WorkStatus.retired, model, pars)
    end
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
    
    person.changeAge(person, person.age + 1//12, model, pars)
    
    if !isSingle(person)
        person.pTime += 1//12
    end
end


