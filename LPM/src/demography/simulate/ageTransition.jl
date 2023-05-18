using Distributions

export selectAgeTransition, ageTransition!, selectWorkTransition, workTransition!


selectAgeTransition(person, pars) = alive(person)

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
        pTime!(person, pTime(person) + 1//12)
    end

    if age(person) == 18
        # also updates guardian
        setAsIndependent!(person)
    end
end

selectWorkTransition(person, pars) = 
    alive(person) && status(person) != WorkStatus.retired && hasBirthday(person)

function computeWage(person, pars)
    # original formula
    # c = log(I/F)
    # wage = F * exp(c * exp(-1 * r * e))

    fI = finalIncome(person)
    iI = initialIncome(person)

    wage = fI * (iI/fI)^exp(-1 * pars.incomeGrowthRate[classRank(person)+1] * workExperience(person))

    dK = rand(Normal(0, pars.wageVar))

    wage * exp(dK)
end


function workTransition!(person, time, model, pars)
    if age(person) == pars.ageTeenagers
        status!(person, WorkStatus.teenager)
        return
    end

    if age(person) == pars.ageOfAdulthood
        status!(person, WorkStatus.student)
        classRank!(person, 0)

        if rand() < pars.probOutOfTownStudent
            outOfTownStudent!(person, true)
        end

        return
    end

    if age(person) == pars.ageOfRetirement
        status!(person, WorkStatus.retired)
        setEmptyJobSchedule!(person)
        wage!(person, 0)

        shareWorkingTime = workingPeriods(person) / pars.minContributionPeriods

        dK = rand(Normal(0, pars.wageVar))
        pension!(person, shareWorkingTime * exp(dK))
        return
    end

    if status(person) == WorkStatus.worker && !isInMaternity(person)
        # we assume full work load at this point
        # in original: availableWorkingHours/workingHours
        workingPeriods!(person, workingPeriods(person)+1)
        # in original: availableWorkingHours/pars.weeklyHours[0]
        workExperience!(person, workExperience(person)+1)
        wage!(person, computeWage(person, pars))
        # no care, therefore full time
        income!(person, wage(person) * pars.weeklyHours[careNeedLevel(person)+1])
    end
end
