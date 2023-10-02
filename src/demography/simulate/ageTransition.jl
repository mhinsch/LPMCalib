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

function computeWage(person, pars)
    # original formula
    # c = log(I/F)
    # wage = F * exp(c * exp(-1 * r * e))

    fI = person.finalWage
    iI = person.initialWage

    wage = fI * (iI/fI)^exp(-pars.incomeGrowthRate[person.classRank+1] * person.workExperience)

    dK = rand(Normal(0, pars.wageVar))

    wage * exp(dK)
end


function workTransition!(person, time, model, pars)
    if person.age == pars.ageTeenagers
        person.status = WorkStatus.teenager
        return
    end

    if person.age == pars.ageOfAdulthood
        person.status = WorkStatus.student
        person.classRank = 0

        if rand() < pars.probOutOfTownStudent
            person.outOfTownStudent = true
        end

        return
    end

    if person.age == pars.ageOfRetirement
        person.status = WorkStatus.retired
        setEmptyJobSchedule!(person)
        person.wage = 0

        shareWorkingTime = person.workingPeriods / pars.minContributionPeriods

        dK = rand(Normal(0, pars.wageVar))
        person.pension = shareWorkingTime * exp(dK)
        return
    end

    if person.status == WorkStatus.worker && !isInMaternity(person)
        # we assume full work load at this point
        # in original: availableWorkingHours/workingHours
        person.workingPeriods = person.workingPeriods+1
        # in original: availableWorkingHours/pars.weeklyHours[0]
        person.workExperience = person.workExperience+1
        person.wage = computeWage(person, pars)
        # no care, therefore full time
        # TODO remove, use jobmarket instead
        person.income = person.wage * pars.weeklyHours[person.careNeedLevel+1]
    end
end
