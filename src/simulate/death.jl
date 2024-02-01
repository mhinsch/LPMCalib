using Utilities

export death!, setDead! 

function deathProbability(baseRate, person, model, pars) 
    # cap age at 150 for admin reasons
    if person.age >= 150
        return 1.0
    end

    cRank = person.classRank
    if person.status == WorkStatus.child || person.status == WorkStatus.student
        cRank = person.parentClassRank
    end

    if isMale(person) 
        mortalityBias = pars.maleMortalityBias
    else 
        mortalityBias = pars.femaleMortalityBias 
    end 

    a = isMale(person) ? model.deathCache.classBias_m : model.deathCache.classBias_f

    if a > 0
        lowClassRate = baseRate / a
        classRate = lowClassRate * mortalityBias^cRank
        deathProb = classRate
    else
        deathProb = baseRate
    end
           
    b = model.deathCache.careBias[cRank+1]
            
    if b > 0
        higherNeedRate = deathProb/b
        deathProb = higherNeedRate * pars.careNeedBias^(pars.numCareLevels-1-person.careNeedLevel) 
    end
    
    deathProb 
end # function deathProb


function setDead!(person) 
    person.alive = false
    resetHouse!(person)
    if !isSingle(person) 
        resolvePartnership!(person.partner,person)
    end

    # dead persons are no longer dependents
    setAsIndependent!(person)

    # dead persons no longer have to be provided for
    setAsSelfproviding!(person)

    for p in person.providees
        p.provider = undefinedPerson
        # TODO update provision/work status
    end
    empty!(person.providees)
    
    removeAllCareAndTasks!(person)
    
    # dependents are being taken care of by assignGuardian!
    nothing
end 

mutable struct DeathCache
    avgDieProb_m :: Float64
    avgDieProb_f :: Float64
    classBias_m :: Float64
    classBias_f :: Float64
    careBias :: Vector{Float64}
end

DeathCache() = DeathCache(0.0, 0.0, 0.0, 0.0, [])

function deathPreCalc!(model, pars)
    pc = model.deathCache
    
    careNeedShares = zeros(length(pars.cumProbClasses), pars.numCareLevels)    
    s_m = 0.0
    s_f = 0.0
    n_m = 0
    n_f = 0
    for agent in model.pop
        if isMale(agent)
            s_m += ageDieProb(pars, yearsold(agent), true)
            n_m += 1
        else
            s_f += ageDieProb(pars, yearsold(agent), false)
            n_f += 1
        end
        careNeedShares[agent.classRank+1, agent.careNeedLevel+1] += 1
    end
   
    pc.avgDieProb_m = s_m / n_m
    pc.avgDieProb_f = s_f / n_f
    
    pc.classBias_m = sumClassBias(c -> model.socialCache.socialClassShares[c+1], 
        0:(length(pars.cumProbClasses)-1), 
        pars.maleMortalityBias)
    pc.classBias_f = sumClassBias(c -> model.socialCache.socialClassShares[c+1], 
        0:(length(pars.cumProbClasses)-1), 
        pars.femaleMortalityBias)
        
    # normalise by population per class
    s = sum(careNeedShares, dims=1)
    careNeedShares ./= s
       
    pc.careBias = [ 
        sum(1:pars.numCareLevels) do i
            careNeedShares[classRank, i] * pars.careNeedBias^(pars.numCareLevels-i)
        end for classRank in 1:length(pars.cumProbClasses) ]
end


ageDieProb(pars, agep, malep) = pars.baseDieProb + (malep ? 
                            exp(agep / pars.maleAgeScaling)  * pars.maleAgeDieProb : 
                            exp(agep / pars.femaleAgeScaling) * pars.femaleAgeDieProb)
                            
                            
# currently leaves dead agents in population
function death!(person, currstep, model, parameters)

    (curryear,currmonth) = date2yearsmonths(currstep)
    currmonth += 1 # adjusting 0:11 => 1:12 

    agep = trunc(Int, person.age)             

    assumption() do
        @assert person.alive       
        @assert isMale(person) || isFemale(person) 
    end
 
    if curryear < 1950 # made-up probabilities
        yearIdx = trunc(Int, curryear - parameters.startTime + 1)
                        
        if agep < 1
            rawRate = model.pre51Deaths[yearIdx, 2] / 1000.0 # infant mortality is per 1k
        else
            rawRate = model.pre51Deaths[yearIdx, 1] * 
                ageDieProb(parameters, agep, isMale(person)) / 
                    (isMale(person) ? 
                        model.deathCache.avgDieProb_m : model.deathCache.avgDieProb_f) 
        end 
    else                         
            
        agep = min(agep, 109)
        rawRate = isMale(person) ?  model.deathMale[agep+1,curryear-1950+1] : 
                                    model.deathFemale[agep+1,curryear-1950+1]
                                   
    end # currYear < 1950 
                        
    deathProb = limit(0.0, deathProbability(rawRate, person, model, parameters), 1.0)
                        
    if rand() < p_yearly2monthly(deathProb)
        setDead!(person) 
        return true 
        # person.deadYear = self.year  
    end # rand

    false
end 

