using Utilities

export death!, setDead! 

function deathProbability(baseRate, person, model, parameters) 
    cRank = classRank(person)
    if status(person) == WorkStatus.child || status(person) == WorkStatus.student
        cRank = parentClassRank(person)
    end

    if isMale(person) 
        mortalityBias = parameters.maleMortalityBias
    else 
        mortalityBias = parameters.femaleMortalityBias 
    end 

    a = isMale(person) ? model.deathCache.classBias_m : model.deathCache.classBias_f
    #sumClassBias(c -> model.socialCache.socialClassShares[c+1], 
    #        0:(length(parameters.cumProbClasses)-1), 
    #        mortalityBias)

    if a > 0
        lowClassRate = baseRate / a
        classRate = lowClassRate * mortalityBias^cRank
        deathProb = classRate
    else
        deathProb = baseRate
    end
           
        #=
        b = 0
        for i in range(int(self.p['numCareLevels'])):
            b += self.careNeedShares[classRank][i]*math.pow(self.p['careNeedBias'], (self.p['numCareLevels']-1) - i)
                
        if b > 0:
            higherNeedRate = classRate/b
            deathProb = higherNeedRate*math.pow(self.p['careNeedBias'], (self.p['numCareLevels']-1) - person.careNeedLevel) # deathProb
=#
        ##### Temporarily by-passing the effect of Unmet Care Need   #############
        
    #   The following code is already commented in the python code 
    #   a = 0
    #   for x in classPop:
    #   a += math.pow(self.p['unmetCareNeedBias'], 1-x.averageShareUnmetNeed)
    #   higherUnmetNeed = (classRate*len(classPop))/a
    #   deathProb = higherUnmetNeed*math.pow(self.p['unmetCareNeedBias'], 1-shareUnmetNeed)            
    deathProb 
end # function deathProb


function setDead!(person) 
    alive!(person, false)
    resetHouse!(person)
    if !isSingle(person) 
        resolvePartnership!(partner(person),person)
    end

    # dead persons are no longer dependents
    setAsIndependent!(person)

    # dead persons no longer have to be provided for
    setAsSelfproviding!(person)

    for p in providees(person)
        provider!(p, undefinedPerson)
        # TODO update provision/work status
    end
    empty!(providees(person))

    # dependents are being taken care of by assignGuardian!
    nothing
end 

mutable struct DeathCache
    avgDieProb_m :: Float64
    avgDieProb_f :: Float64
    classBias_m :: Float64
    classBias_f :: Float64
end

DeathCache() = DeathCache(0.0, 0.0, 0.0, 0.0)

function deathPreCalc!(model, pars)
    pc = model.deathCache
    
    s_m = 0.0
    s_f = 0.0
    n_m = 0
    n_f = 0
    for p in model.pop
        if isMale(p)
            s_m += ageDieProb(pars, yearsold(p), true)
            n_m += 1
        else
            s_f += ageDieProb(pars, yearsold(p), false)
            n_f += 1
        end
    end
   
    pc.avgDieProb_m = s_m / n_m
    pc.avgDieProb_f = s_f / n_f
    
    pc.classBias_m = sumClassBias(c -> model.socialCache.socialClassShares[c+1], 
        0:(length(pars.cumProbClasses)-1), 
        pars.maleMortalityBias)
    pc.classBias_f = sumClassBias(c -> model.socialCache.socialClassShares[c+1], 
        0:(length(pars.cumProbClasses)-1), 
        pars.femaleMortalityBias)
end


ageDieProb(pars, agep, malep) = pars.baseDieProb + (malep ? 
                            exp(agep / pars.maleAgeScaling)  * pars.maleAgeDieProb : 
                            exp(agep / pars.femaleAgeScaling) * pars.femaleAgeDieProb)
                            
                            
# currently leaves dead agents in population
function death!(person, currstep, model, parameters)

    (curryear,currmonth) = date2yearsmonths(currstep)
    currmonth += 1 # adjusting 0:11 => 1:12 

    agep = trunc(Int, age(person))             

    assumption() do
        @assert alive(person)       
        @assert isMale(person) || isFemale(person) # Assumption 
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
                        
    #=
        Not realized yet 
        classPop = [x for x in self.pop.livingPeople 
                        if x.careNeedLevel == person.careNeedLevel]
        Classes to be considered in a different module 
    =#
                        
    deathProb = limit(0.0, deathProbability(rawRate, person, model, parameters), 1.0)
                        
    #=
        The following is uncommented code in the original code < 1950
        #### Temporarily by-passing the effect of unmet care need   ######
        # dieProb = self.deathProb_UCN(rawRate, person.parentsClassRank, person.careNeedLevel, person.averageShareUnmetNeed, classPop)
    =# 
                                
    if rand() < p_yearly2monthly(deathProb)
        setDead!(person) 
        return true 
        # person.deadYear = self.year  
    end # rand

    false
end 

