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

"evaluate death events in a population"
function doDeaths!(;people,parameters,data,currstep,verbose=true,sleeptime=0)

    (curryear,currmonth) = date2yearsmonths(Rational(currstep))
    currmonth = currmonth + 1 # adjusting 0:11 => 1:12 
    numDeaths = 0

    for person in people 

        @assert alive(person)       
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
        
        if rand() < dieProb && rand(1:12) == currmonth 
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
end  # function doDeaths! 

"""
    Accept a population and evaluates the birth rate upon computing
    - the population of married fertile women according to 
      fixed parameters (minPregnenacyAge, maxPregnenacyAge) and 
    - the birth probability data (fertility bias and growth rates) 

    Class rankes and shares are temporarily ignored.

"""
function doBirths!(;people,parameters,data,currstep,
                    verbose=true,sleeptime=0,checkassumption=true)

    (curryear,currmonth) = date2yearsmonths(Rational(currstep))
    currmonth = currmonth + 1   # adjusting 0:11 => 1:12 
    numBirths = 0

    # TODO Assumptions 
    if checkassumption
        for person in people  
            @assert alive(person) 
        end
    end 

    preBirth = length(people)
    births =  0    # instead of [0, 0, 0, 0, 0]
    marriedPercentage = -1  # []

    # TODO The following could be collapsed into one loop / not sure if it is more efficient 
    #      there is also a potential to save alot of re-computation in each iteration by 
    #      storing the intermediate results and modifying the computation.
    #      However, it could be also the case that Julia compiler does something efficient any way? 

    allFemals = [ female for female in people if isFemale(female) ]
    adultWomen = [ aWomen for aWomen in allFemales if age(aWomen) >= parameters.minPregnancyAge ]
    notFertiledWomen = [ nfWoman for nfWomen in adultWomen if age(nfWoman) > parameters.maxPregnancyAge ]

    womenOfReproductiveAge = [ rWoman for rWoman in adultWomen if age(rWoman) <= parameters.maxPregnancyAge ]
    womenOfReproductiveAgeButNotMarried = [ rnmWoman for rnmWoman in womenOfReproductiveAge if isSingle(rnmWoman) ]

    # TODO @assumption 
    if checkassumption
        nonadultFemale = allFemales - adultWomen
        for female in nonadultFemale
            @asset( isSingle(female))   
        end
    end

    #        for person in self.pop.livingPeople:
    #           
    #            if person.sex == 'female' and person.age >= self.p['minPregnancyAge']:
    #                adultLadies += 1
    #                if person.partner != None:
    #                    marriedLadies += 1
    #        marriedPercentage = float(marriedLadies)/float(adultLadies)

    numMarriedLadies = length(womenOfReproductiveAge) - length(womenOfReproductiveAgeButNotMarried) 
    marriedPercentage = numMarriedLadies / length(adultLadies)

    if verbose

        # To do this generic print msg to be placed in a top function 
        println("In iteration $curryear , month $currmonth :")

        println("# allFemales    : $(length(allFemales))") 
        println("# adult women   : $(length(adultWomen))") 
        println("# NotFertile    : $(length(notFertiledWomen))")

        println("# fertile women : $(length(womenOfReproductiveAge))")
        println("# non-married fertile women : $(length(womenOfReproductiveAgeButNotMarried))")

        println("marriedPercentage : $marriedPercentage")

        sleep(sleeptime)

    end # verbose 


    #=      
        adultLadies_1 = [x for x in adultWomen if x.classRank == 0]   
        marriedLadies_1 = len([x for x in adultLadies_1 if x.partner != None])
        if len(adultLadies_1) > 0:
            marriedPercentage.append(marriedLadies_1/float(len(adultLadies_1)))
        else:
            marriedPercentage.append(0)
        adultLadies_2 = [x for x in adultWomen if x.classRank == 1]    
        marriedLadies_2 = len([x for x in adultLadies_2 if x.partner != None])
        if len(adultLadies_2) > 0:
            marriedPercentage.append(marriedLadies_2/float(len(adultLadies_2)))
        else:
            marriedPercentage.append(0)
        adultLadies_3 = [x for x in adultWomen if x.classRank == 2]   
        marriedLadies_3 = len([x for x in adultLadies_3 if x.partner != None]) 
        if len(adultLadies_3) > 0:
            marriedPercentage.append(marriedLadies_3/float(len(adultLadies_3)))
        else:
            marriedPercentage.append(0)
        adultLadies_4 = [x for x in adultWomen if x.classRank == 3]  
        marriedLadies_4 = len([x for x in adultLadies_4 if x.partner != None])   
        if len(adultLadies_4) > 0:
            marriedPercentage.append(marriedLadies_4/float(len(adultLadies_4)))
        else:
            marriedPercentage.append(0)
        adultLadies_5 = [x for x in adultWomen if x.classRank == 4]   
        marriedLadies_5 = len([x for x in adultLadies_5 if x.partner != None]) 
        if len(adultLadies_5) > 0:
            marriedPercentage.append(marriedLadies_5/float(len(adultLadies_5)))
        else:
            marriedPercentage.append(0)
    =#
        
    for woman in womenOfReproductiveAge:

        # womanClassRank = woman.classRank
        #   if woman.status == 'student':
        #       womanClassRank = woman.parentsClassRank

    end
    
    #=    
        for woman in womenOfReproductiveAge:
            
            

            if self.year < 1951:
                rawRate = self.p['growingPopBirthProb']
                birthProb = self.computeBirthProb(self.p['fertilityBias'], rawRate, womanClassRank)
            else:
                rawRate = self.fert_data[(self.year - woman.birthdate)-16, self.year-1950]
                birthProb = self.computeBirthProb(self.p['fertilityBias'], rawRate, womanClassRank)/marriedPercentage[womanClassRank]
                
            # birthProb = self.computeBirthProb(self.p['fertilityBias'], rawRate, woman.classRank)
            
            #baseRate = self.baseRate(self.socialClassShares, self.p['fertilityBias'], rawRate)
            #fertilityCorrector = (self.socialClassShares[woman.classRank] - self.p['initialClassShares'][woman.classRank])/self.p['initialClassShares'][woman.classRank]
            #baseRate *= 1/math.exp(self.p['fertilityCorrector']*fertilityCorrector)
            #birthProb = baseRate*math.pow(self.p['fertilityBias'], woman.classRank)
            if birthProb <= 0.0:
                print 'Error: birth prob is zeo/negative!'
                sys.exit()
                
            if np.random.random() < birthProb and np.random.choice([x+1 for x in range(12)]) == month:
                # (self, mother, father, age, birthYear, sex, status, house,
                # classRank, sec, edu, wage, income, finalIncome):
                parentsClassRank = max([woman.classRank, woman.partner.classRank])
                baby = Person(woman, woman.partner, self.year, 0, 'random', woman.house, woman.sec, -1, parentsClassRank, 0, 0, 0, 0, 0, 0, 'child', False, 0, month)
                self.pop.allPeople.append(baby)
                self.pop.livingPeople.append(baby)
                woman.house.occupants.append(baby)
                woman.children.append(baby)
                woman.partner.children.append(baby)
                woman.maternityStatus = True
                # woman.weeklyTime = [[0]*12+[1]*12, [0]*12+[1]*12, [0]*12+[1]*12, [0]*12+[1]*12, [0]*12+[1]*12, [0]*12+[1]*12, [0]*12+[1]*12]
                woman.weeklyTime = [[1]*24, [1]*24, [1]*24, [1]*24, [1]*24, [1]*24, [1]*24]
                woman.workingHours = 0
                woman.maxWeeklySupplies = [0, 0, 0, 0]
                woman.residualDailySupplies = [0]*7
                woman.residualWeeklySupplies = [x for x in woman.maxWeeklySupplies]
                woman.residualWorkingHours = 0
                woman.availableWorkingHours = 0
                woman.potentialIncome = 0
                woman.income = 0
                if woman.house == self.displayHouse:
                    messageString = str(self.year) + ": #" + str(woman.id) + " had a baby, #" + str(baby.id) + "." 
                    self.textUpdateList.append(messageString)
                    
                    with open(os.path.join(policyFolder, "Log.csv"), "a") as file:
                        writer = csv.writer(file, delimiter = ",", lineterminator='\r')
                        writer.writerow([self.year, messageString])
                    
        postBirth = len(self.pop.livingPeople)
        numberBirths = postBirth - preBirth
        print 'The number of births is: ' + str(numberBirths)


    =# 


end  # function doBirths! 



end # module Simulate 