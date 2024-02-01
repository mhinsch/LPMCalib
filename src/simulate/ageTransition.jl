using Distributions

export selectAgeTransition, ageTransition!, selectWorkTransition, workTransition!


selectAgeTransition(person, pars) = true

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
    
    person.age += 1//12
    
    # child ages out of care need this time step
    if person.age == pars.childCareAge + 1//12
        careNeedChanged!(person, pars)
    end
    
    if !isSingle(person)
        person.pTime += 1//12
    end

    if person.age == 18
        # also updates guardian
        setAsIndependent!(person)
    end
end


selectWorkTransition(person, pars) = 
    person.status != WorkStatus.retired && hasBirthday(person)
    
"Update work-related status dependent on age."
function workTransition!(person, time, model, pars)
    if person.age == pars.ageTeenagers
        person.status = WorkStatus.teenager
        return
    end
    
    # all agents first become students, start working in social transition
    if person.age == pars.ageOfAdulthood
        person.status = WorkStatus.student
        person.classRank = 0

        return
    end

    if person.age == pars.ageOfRetirement
        person.status = WorkStatus.retired
        setEmptyJobSchedule!(person)
        person.wage = 0

        shareWorkingTime = person.workingPeriods / pars.minContributionPeriods

        dK = rand(Normal(0, pars.wageVar))
        person.pension = person.lastIncome * shareWorkingTime * exp(dK)
        return
    end
end
