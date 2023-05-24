using Distributions
using Utilities

export selectSocialCareTransition, socialCareTransition!


function selectSocialCareTransition(p, pars)
    true
end


mutable struct SocialCareCache
    classBias :: Vector{Float64}
end

SocialCareCache() = SocialCareCache([])


function socialCarePreCalc!(model, pars)
    pc = model.socialCareCache
    resize!(pc.classBias, 5)
    classes = 0:(length(pars.cumProbClasses)-1)
    preCalcRateBias!(classes, pars.careBias, pc.classBias, 1) do c
        model.socialCache.socialClassShares[c+1]
    end
end

#=function classSocialCareBias(model, pars, class)
    classes = 0:(length(pars.cumProbClasses)-1)
    rateBias(classes, pars.careBias, class) do c
        model.socialCache.socialClassShares[c+1]
    end
end=#

function socialCareTransition!(person, time, model, pars)
    scaling = isFemale(person) ? pars.femaleAgeCareScaling : pars.maleAgeCareScaling 
    ageCareProb = exp(age(person)/scaling) * pars.personCareProb
    
    baseProb = pars.baseCareProb + ageCareProb
  
    class = classRank(person) 
    if status(person) == WorkStatus.child || status(person) == WorkStatus.student
        class = parentClassRank(person)
    end
    
    #baseProb *= classSocialCareBias(model, pars, class)
    baseProb *= model.socialCareCache.classBias[class+1]
    
    if rand() > p_yearly2monthly(limit(0.0, baseProb, 1.0))
        return false
    end
   
    #transitionRate = pars.careTransitionRate * classSocialCareBias(model, pars, class)
    transitionRate = pars.careTransitionRate * model.socialCareCache.classBias[class+1]
    
    careNeed = careNeedLevel(person) + rand(Geometric(1.0-transitionRate)) + 1
    # careLevel is 0-based
    careNeedLevel!(person, min(careNeed, numCareLevels(pars)-1))
    true
end

    
