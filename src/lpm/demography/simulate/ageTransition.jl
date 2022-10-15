using Distributions

using XAgents

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

    if age(person) == 18
        # also updates guardian
        setAsIndependent!(person)
    end
end

selectWorkTransition(person, pars) = 
    alive(person) && status(person) != WorkStatus.retired && hasBirthday(person)


function workTransition!(person, time, model, pars)
    if age(person) == pars.ageTeenagers
        status!(person, WorkStatus.teenager)
        return
    end

    if age(person) == pars.ageOfAdulthood
        status!(person, WorkStatus.student)
        #class!(person, 0)

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
    end
end
