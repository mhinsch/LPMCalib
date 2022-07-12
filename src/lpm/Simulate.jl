"""
    Main simulation functions for the demographic aspect of LPM. 
""" 


module Simulate

using XAgents: Person  
using XAgents: isMale, isFemale, isSingle
using XAgents: removeOccupant!, resolvePartnership!

using MultiAgents: ABM, allagents

using MultiAgents.Util: date2yearsmonths
using LoneParentsModel.Create: LPMUKDemographyOpt

export doDeaths!


function deathProbability(baseRate,person,parameters) 
    #=
        Not realized yet  / to be realized in another module? 

        classRank = person.classRank
        if person.status == 'child' or person.status == 'student':
            classRank = person.parentsClassRank
    =# 

    @assert isMale(person) || isFemale(person) # Assumption  
    mortalityBias = isMale(person) ? parameters[:maleMortalityBias] : 
                                     parameters[:femaleMortalityBias] 

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
        
#        The following code is already commented in the python code 
#        a = 0
#        for x in classPop:
#            a += math.pow(self.p['unmetCareNeedBias'], 1-x.averageShareUnmetNeed)
#        higherUnmetNeed = (classRate*len(classPop))/a
#        deathProb = higherUnmetNeed*math.pow(self.p['unmetCareNeedBias'], 1-shareUnmetNeed)            
     

    deathProb 
end # function deathProb


function doDeaths!(population::ABM{Person};
                   verbose = true, sleeptime=0) 

    parameters = population.properties 

    (curryear,currmonth) = date2yearsmonths(Rational(population.properties[:currstep]))
    currmonth = currmonth + 1 

    people = allagents(population)

    livingPeople = typeof(population.properties[:example]) == LPMUKDemographyOpt ? 
        people : [person for person in people if alive(person)]

    @assert length(livingPeople) > 0 ? 
        typeof(age(livingPeople[1])) == Rational{Int64} :
        true  # Assumption

    for person in livingPeople

        @assert isMale(person) || isFemale(person) # Assumption 
        age = age(person) 
        dieProb = 0
        lifeExpectancy = 0  # From the code but does not play and rule?

        if curryear >= 1950 

            age = age > 109 ? Rational(109) : age
            ageindex = trunc(Int,age)
            rawRate = isMale(person) ? 
                population.data[:death_male][ageindex+1,curryear-1950+1] : 
                population.data[:death_female][ageindex+1,curryear-1950+1]
           
            lifeExpectancy = max(90 - age, 3 // 1)  ## ??? 
           
        else # curryear < 1950 / made-up probabilities 

            babyDieProb = age < 1 ? parameters[:babyDieProb] : 0.0 
            ageDieProb  = isMale(person) ? 
                exp(age / parameters[:maleAgeScaling])  * parameters[:maleAgeDieProb] : 
                exp(age / parameters[:femaleAgeScaling]) * parameters[:femaleAgeDieProb]
            rawRate = parameters[:baseDieProb] + babyDieProb + ageDieProb
            
            lifeExpectancy = max(90 - age, 5 // 1)  ## ??? 

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
                y, m = date2yearsmonths(age)
                println("person $(person.id) died year $(curryear) with age of $y")
                sleep(sleeptime) 
            end
            setDead!(person) 
            # person.deadYear = self.year  # to be moved to agent_step!
            # deaths[person.classRank] += 1
            false ? population.variables[:numberDeaths] += 1 : nothing # Temporarily this way till realized 
            removeOccupant!(person.pos,person)
            if ! isSingle(person)
                resolvePartnership!(person, partner(person))
            end
        end # rand

    end # for livingPeople
    
    if verbose
        println("number of living people : $(length(livingPeople)) from $(length(people))") 
        sleep(sleeptime)
    end 

end # function doDeaths!



end # Simulate 
