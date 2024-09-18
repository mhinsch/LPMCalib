module SocialCare


using Distributions
using Utilities
using BasicInfoAM, WorkAM
using CareCM
using TasksCare

export selectSocialCareTransition, socialCareTransition!, socialCarePreCalc!
export SocialCareCache


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

"Adjust social care need."
function socialCareTransition!(person, time, model, pars)
    scaling = isFemale(person) ? pars.femaleAgeCareScaling : pars.maleAgeCareScaling 
    ageCareProb = exp(person.age/scaling) * pars.personCareProb
    
    baseProb = pars.baseCareProb + ageCareProb
  
    class = person.classRank 
    if person.status == WorkStatus.child || person.status == WorkStatus.student
        class = person.parentClassRank
    end
    
    #baseProb *= classSocialCareBias(model, pars, class)
    baseProb *= model.socialCareCache.classBias[class+1]
    
    if rand() > p_yearly2monthly(limit(0.0, baseProb, 1.0))
        return false
    end
   
    #transitionRate = pars.careTransitionRate * classSocialCareBias(model, pars, class)
    transitionRate = pars.careTransitionRate * model.socialCareCache.classBias[class+1]
    
    careNeed = person.careNeedLevel + rand(Geometric(1.0-transitionRate)) + 1
    # careLevel is 0-based
    person.careNeedLevel = min(careNeed, numCareLevels(pars)-1)
    
    careNeedChanged!(person, pars)
    careSupplyChanged!(person, pars)
    
    true
end


end
