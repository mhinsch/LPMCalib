using Utilities
using XAgents

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

    a = 0
    for i in 1:length(parameters.cumProbClasses)
        c = i - 1 # class is 0-based!
        a += socialClassShares(model, c) * mortalityBias^(c)
    end

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
    person.info.alive = false
    resetHouse!(person)
    if !isSingle(person) 
        resolvePartnership!(partner(person),person)
    end

    # dead persons are no longer dependents
    setAsIndependent!(person)

    # dead persons no longer have to be provided for
    setAsSelfproviding!(person)

    for p in providees(person)
        provider!(p, nothing)
        # TODO update provision/work status
    end
    empty!(providees(person))

    # dependents are being taken care of by assignGuardian!
    nothing
end 


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
                        
        babyDieProb = agep < 1 ? parameters.babyDieProb : 0.0 
        ageDieProb  = isMale(person) ? 
                        exp(agep / parameters.maleAgeScaling)  * parameters.maleAgeDieProb : 
                        exp(agep / parameters.femaleAgeScaling) * parameters.femaleAgeDieProb
        rawRate = parameters.baseDieProb + babyDieProb + ageDieProb
                                    
        # lifeExpectancy = max(90 - agep, 5 // 1)  # ??? Does not currently play any role
                        
    else                         
            
        agep = min(agep, 109)
        rawRate = isMale(person) ?  model.deathMale[agep+1,curryear-1950+1] : 
                                    model.deathFemale[agep+1,curryear-1950+1]
                                   
        # lifeExpectancy = max(90 - agep, 3 // 1)  # ??? This is a direct translation 
                        
    end # currYear < 1950 
                        
    #=
        Not realized yet 
        classPop = [x for x in self.pop.livingPeople 
                        if x.careNeedLevel == person.careNeedLevel]
        Classes to be considered in a different module 
    =#
                        
    deathProb = min(1.0, deathProbability(rawRate, person, model, parameters))
                        
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

