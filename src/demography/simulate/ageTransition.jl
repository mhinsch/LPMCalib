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
        pTime!(person, person.pTime + 1//12)
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

    fI = person.finalIncome
    iI = person.initialIncome

    wage = fI * (iI/fI)^exp(-1 * pars.incomeGrowthRate[person.classRank+1] * person.workExperience)

    dK = rand(Normal(0, pars.wageVar))

    wage * exp(dK)
end


function workTransition!(person, time, model, pars)
    if person.age == pars.ageTeenagers
        status!(person, WorkStatus.teenager)
        return
    end

    if person.age == pars.ageOfAdulthood
        status!(person, WorkStatus.student)
        classRank!(person, 0)

        if rand() < pars.probOutOfTownStudent
            outOfTownStudent!(person, true)
        end

        return
    end

    if person.age == pars.ageOfRetirement
        status!(person, WorkStatus.retired)
        setEmptyJobSchedule!(person)
        wage!(person, 0)

        shareWorkingTime = person.workingPeriods / pars.minContributionPeriods

        dK = rand(Normal(0, pars.wageVar))
        pension!(person, shareWorkingTime * exp(dK))
        return
    end

    if person.status == WorkStatus.worker && !isInMaternity(person)
        # we assume full work load at this point
        # in original: availableWorkingHours/workingHours
        workingPeriods!(person, person.workingPeriods+1)
        # in original: availableWorkingHours/pars.weeklyHours[0]
        workExperience!(person, person.workExperience+1)
        wage!(person, computeWage(person, pars))
        # no care, therefore full time
        income!(person, person.wage * pars.weeklyHours[person.careNeedLevel+1])
    end
end
