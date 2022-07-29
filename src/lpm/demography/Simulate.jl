"""
Functions used for demography simulation 
"""

module Simulate

using SomeUtil: date2yearsmonths
using XAgents: resetHouse!, resolvePartnership!, setDead!
using XAgents: isMale, isFemale, isSingle, age, partner, alive

export doDeaths!

function deathProbability(baseRate,person,parameters) 
    #=
        Not realized yet  / to be realized in another module? 
        classRank = person.classRank
        if person.status == 'child' or person.status == 'student':
            classRank = person.parentsClassRank
    =# 

    @assert isMale(person) || isFemale(person) # Assumption  
    mortalityBias = isMale(person) ? parameters.maleMortalityBias : 
                                     parameters.femaleMortalityBias 

    #= 
    To be integrated in class modules 
    a = 0
    for i in range(int(self.p['numberClasses'])):
        a += self.socialClassShares[i]*math.pow(mortalityBias, i)
    =# 

    #=
    if a > 0:
        lowClassRate = baseRate/a
        classRate = lowClassRate*math.pow(mortalityBias, classRank)
        deathProb = classRate
           
        b = 0
        for i in range(int(self.p['numCareLevels'])):
            b += self.careNeedShares[classRank][i]*math.pow(self.p['careNeedBias'], (self.p['numCareLevels']-1) - i)
                
        if b > 0:
            higherNeedRate = classRate/b
            deathProb = higherNeedRate*math.pow(self.p['careNeedBias'], (self.p['numCareLevels']-1) - person.careNeedLevel) # deathProb
    =#

    # assuming it is just one class and without care need, 
    # the above code translates to: 

    deathProb = baseRate * mortalityBias 

        ##### Temporarily by-passing the effect of Unmet Care Need   #############
        
    #   The following code is already commented in the python code 
    #   a = 0
    #   for x in classPop:
    #   a += math.pow(self.p['unmetCareNeedBias'], 1-x.averageShareUnmetNeed)
    #   higherUnmetNeed = (classRate*len(classPop))/a
    #   deathProb = higherUnmetNeed*math.pow(self.p['unmetCareNeedBias'], 1-shareUnmetNeed)            
     

    deathProb 
end # function deathProb

""
function doDeaths!(;people,parameters,data,verbose=true,sleeptime=0)

    println(parameters)
    (curryear,currmonth) = date2yearsmonths(Rational(parameters.currstep))
    currmonth = currmonth + 1 
    numDeaths = 0

    for person in people 

        # @assert person.info.alive      
        @assert isMale(person) || isFemale(person) # Assumption 
        
        agep = age(person)             
        @assert typeof(agep) == Rational{Int64}
        dieProb = 0
        lifeExpectancy = 0  # From the code but does not play and rule?

        if curryear >= 1950 

            agep = agep > 109 ? Rational(109) : agep 
            ageindex = trunc(Int,agep)
            rawRate = isMale(person) ? data.death_male[ageindex+1,curryear-1950+1] : 
                                       data.death_female[ageindex+1,curryear-1950+1]
           
            lifeExpectancy = max(90 - agep, 3 // 1)  # ??? This is a direct translation 

        else # curryear < 1950 / made-up probabilities 

            babyDieProb = agep < 1 ? parameters.babyDieProb : 0.0 
            ageDieProb  = isMale(person) ? 
                            exp(agep / parameters.maleAgeScaling)  * parameters.maleAgeDieProb : 
                            exp(agep / parameters.femaleAgeScaling) * parameters.femaleAgeDieProb
            rawRate = parameters.baseDieProb + babyDieProb + ageDieProb
            
            lifeExpectancy = max(90 - agep, 5 // 1)  # ??? Does not currently play any role

        end # currYear < 1950 

        #=
        Not realized yet 
        classPop = [x for x in self.pop.livingPeople 
                      if x.careNeedLevel == person.careNeedLevel]
        Classes to be considered in a different module 
        =#

        dieProb =  deathProbability(rawRate,person,parameters)

        #=
        The following is uncommented code in the original code < 1950
        #### Temporarily by-passing the effect of unmet care need   ######
        # dieProb = self.deathProb_UCN(rawRate, person.parentsClassRank, person.careNeedLevel, person.averageShareUnmetNeed, classPop)
        =# 
        
        if rand() < dieProb && rand(1:12) == currmonth && alive(person)   
            if verbose 
                y, m = date2yearsmonths(agep)
                println("person $(person.id) died year $(curryear) with age of $y")
                sleep(sleeptime) 
            end
            setDead!(person) 
            # person.deadYear = self.year  
            # deaths[person.classRank] += 1
            numDeaths += 1 
            resetHouse!(person)
            isSingle(person) ?
                nothing :  
                resolvePartnership!(partner(person),person)
         end # rand

    end # for livingPeople
    
    if verbose
        println("# living people : $(length(people)) , # people died in curr iteration : $(numDeaths)") 
        sleep(sleeptime)
    end 

    (numberDeaths = numDeaths)   
end


end # module Simulate 