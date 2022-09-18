using Distributions

using XAgents: WorkStatus, status, status!, hasBirthday, age, outOfTownStudent!, agestep!
using XAgents: setEmptyJobSchedule!, wage!, pension!, isInMaternity, maternityDuration
using XAgents: stepMaternity!, endMaternity!, workingPeriods

function doAgeTransitions!(people, step, pars)
    
    (year,month) = date2yearsmonths(step)
    month += 1 # adjusting 0:11 => 1:12 

    for person in people

        @assert alive(person)

        if isInMaternity(person)
            # count maternity months
            stepMaternity!(person)

            # end of maternity leave
            if maternityDuration(person) >= pars.maternityLeaveDuration
                endMaternity!(person)
            end
        end

        agestep!(person)

        # TODO part of location module, TBD
        #if hasBirthday(person, month)
        #    person.movedThisYear = false
        #    person.yearInTown += 1
        #end
    end # person in people

    # only process those not retired and born in the current month
    relevant = Iterators.filter(people) do p
        status(p) != WorkStatus.retired && hasBirthday(p)
    end

    for person in relevant
        if age(person) == pars.ageTeenagers
            status!(person, WorkStatus.teenager)
            continue
        end

        if age(person) == pars.ageOfAdulthood
            status!(person, WorkStatus.student)
            #class!(person, 0)

            if rand() < pars.probOutOfTownStudent
                outOfTownStudent!(person, true)
            end

            continue
        end

        if age(person) == pars.ageOfRetirement
            status!(person, WorkStatus.retired)
            setEmptyJobSchedule!(person)
            wage!(person, 0)

            shareWorkingTime = workingPeriods(person) / pars.minContributionPeriods

            dK = rand(Normal(0, pars.wageVar))
            pension!(person, shareWorkingTime * exp(dK))
        end
    end # for person in non-retired

end
