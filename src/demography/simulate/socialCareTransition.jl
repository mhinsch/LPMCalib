using Utilities

export selectSocialCareTransition, socialCareTransition!

socialCareDemand(person, pars) = pars.careDemandInHours[careNeedLevel(person)+1]

numCareLevels(pars) = length(pars.careDemandInHours)

function selectSocialCareTransition(p, pars)
    true
end

function classSocialCareBias(model, pars, class)
    classes = 0:(length(pars.cumProbClasses)-1)
    rateBias(classes, pars.careBias, class) do c
        socialClassShares(model, c)
    end
end

function socialCareTransition!(person, time, model, pars)
    scaling = isFemale(person) ? pars.femaleAgeCareScaling : pars.maleAgeCareScaling 
    ageCareProb = exp(age(person)/scaling) * pars.personCareProb
    
    baseProb = pars.baseCareProb + ageCareProb
  
    class = classRank(person) 
    if status(person) == WorkStatus.child || status(person) == WorkStatus.student
        class = parentClassRank(person)
    end
    
    baseProb *= classSocialCareBias(model, pars, class)
    
    if rand() > p_yearly2monthly(baseProb)
        return nothing
    end
   
    baseTransition = (1.0 - pars.careTransitionRate) * classSocialCareBias(model, pars, class)
    transitionRate = 1.0 - baseTransition
    
    careNeed = careNeedLevel(person)
    bound = transitionRate
    while rand() > bound && careNeed < numCareLevels(pars)
        careNeed += 1
        bound += (1.0 - bound) * transitionRate
    end
    
    careNeedLevel!(person, careNeed)
end
