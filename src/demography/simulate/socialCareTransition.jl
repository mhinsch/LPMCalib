using Distributions
using Utilities

export selectSocialCareTransition, socialCareTransition!


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
        return false
    end
   
    transitionRate = pars.careTransitionRate * classSocialCareBias(model, pars, class)
    
    careNeed = careNeedLevel(person) + rand(Geometric(1.0-transitionRate)) + 1
    careNeedLevel!(person, min(careNeed, numCareLevels(pars)))
    true
end

    
