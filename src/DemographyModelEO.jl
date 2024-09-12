# !CAUTION!
# !DEPRECATED!



module DemographyModelEO

using DemographyModel

export stepModel!


# TODO not entirely sure if this really belongs here
function DemographyModel.stepModel!(model, time, pars)
    println("EO")
    shuffle!(model.pop)
    socialPreCalc!(model, pars)
    socialCarePreCalc!(model, fuse(pars.poppars, pars.carepars))
    divorcePreCalc!(model, fuse(pars.poppars, pars.divorcepars, pars.workpars))
    birthPreCalc!(model, fuse(pars.poppars, pars.birthpars))
    deathPreCalc!(model, pars.poppars)

    selected = Iterators.filter(p->selectAgeTransition(p, pars.workpars), model.pop)
    applyTransition!(selected, "age") do person
        ageTransition!(person, time, model, pars.workpars)
    end

    selected = Iterators.filter(p->selectBirth(p, pars.birthpars), model.pop)
    applyTransition!(selected, "birth") do person
        birth!(person, time, model, fuse(pars.poppars, pars.birthpars), addBaby!)
    end

    orphans = Iterators.filter(p->selectAssignGuardian(p), model.pop)
    applyTransition!(orphans, "adoption") do person
        assignGuardian!(person, time, model, pars)
    end

    selected = Iterators.filter(p->selectWorkTransition(p, pars.workpars), model.pop)
    applyTransition!(selected, "work") do person
        workTransition!(person, time, model, pars.workpars)
    end
    
    selected = Iterators.filter(p->selectSocialTransition(p, pars.workpars), model.pop) 
    applyTransition!(selected, "social") do person
        socialTransition!(person, time, model, pars.workpars) 
    end

    marriagePreCalc!(model, fuse(pars.poppars, pars.marriagepars, pars.birthpars, pars.mappars))
    selected = Iterators.filter(p->selectMarriage(p, pars.workpars), model.pop)
    applyTransition!(selected, "marriage") do person
        marriage!(person, time, model, 
            fuse(pars.poppars, pars.marriagepars, pars.birthpars, pars.mappars))
    end
    
    selected = Iterators.filter(p->selectRelocate(p, pars.workpars), model.pop)
    applyTransition!(selected, "relocate") do person
        relocate!(person, time, model, pars.workpars)
    end

    selected = Iterators.filter(p->selectDivorce(p, pars), model.pop)
    applyTransition!(selected, "divorce") do person
        divorce!(person, time, model, fuse(pars.poppars, pars.divorcepars, pars.workpars))
    end
    
    selected = Iterators.filter(p->selectSocialCareTransition(p, pars.workpars), model.pop)
    applyTransition!(selected, "social care") do person
        socialCareTransition!(person, time, model, fuse(pars.poppars, pars.carepars))
    end
    
    socialCare!(model, pars.carepars)
    
    applyTransition!(model.pop, "death") do person
        death!(person, time, model, pars.poppars)
    end
    removeDead!(model)

    
    append!(model.pop, model.babies)
    empty!(model.babies)
end


end # module DemographyModel
