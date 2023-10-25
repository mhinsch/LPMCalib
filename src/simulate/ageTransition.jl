using Distributions

export selectAgeTransition, ageTransition!, selectWorkTransition, workTransition!


selectAgeTransition(person, pars) = person.alive

function ageTransition!(person, time, model, pars)
    if isInMaternity(person)
        # count maternity months
        stepMaternity!(person)

        # end of maternity leave
        if maternityDuration(person) >= pars.maternityLeaveDuration
            endMaternity!(person)
        end
    end

        # TODO part of location module, TBD
        #if hasBirthday(person, month)
        #    person.movedThisYear = false
        #    person.yearInTown += 1
        #end
    agestep!(person)
    
    # TODO parameterise dt
    if !isSingle(person)
        person.pTime = person.pTime + 1//12
    end

    if person.age == 18
        # also updates guardian
        setAsIndependent!(person)
    end
end

selectWorkTransition(person, pars) = 
    person.alive && person.status != WorkStatus.retired && hasBirthday(person)
    
function workTransition!(person, time, model, pars)
    if person.age == pars.ageTeenagers
        person.status = WorkStatus.teenager
        return
    end

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

    #person.income = person.wage * pars.weeklyHours[person.careNeedLevel+1]
end
