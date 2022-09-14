"""
Functions used for demography simulation 
"""

module Simulate

# we want the lazy version of filter
using Distributions: Normal, LogNormal

using SomeUtil: date2yearsmonths
using Utilities: Gender, unknown, female, male
using XAgents: Person
using XAgents: resetHouse!, resolvePartnership!, setDead!
using XAgents: isMale, isFemale, isSingle, age, partner, alive, hasChildren, agestep!
using XAgents: hasBirthday, ageYoungestAliveChild

using XAgents: giveBirth!, stepMaternity!, resetMaternity!, isInMaternity, 
    maternityDuration

using XAgents: Work, status, outOfTownStudent, newEntrant, wage, income, 
    jobTenure, schedule, workingHours, workingPeriods, pension
using XAgents: status!, outOfTownStudent!, newEntrant!, wage!, income!, jobTenure!, schedule!, 
    workingHours!, workingPeriods!, pension!

export doDeaths!, doBirths!, doAgeTransitions!

const I = Iterators


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
function doDeaths!(;people,parameters,data,currstep,
                    verbose=true,sleeptime=0,checkassumption=true)

    (curryear,currmonth) = date2yearsmonths(Rational(currstep))
    currmonth = currmonth + 1 # adjusting 0:11 => 1:12 
    deads = Person[] 

    count = 0

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
            push!(deads,person)
            # person.deadYear = self.year  
            # deaths[person.classRank] += 1
        else # person survived
            count += 1
        end # rand

    end # for livingPeople
    
    if verbose
        numDeaths = length(deads)
        println("# living people : $(count+numDeaths), # people died in curr iteration : $(numDeaths)") 
        sleep(sleeptime)
    end 

    (deadpeople = deads)   
end  # function doDeaths! 

         
function computeBirthProb(rWoman,parameters,data,currstep,
                          verbose=true,sleeptime=0,checkassumption=true)
    
    if checkassumption 
        @assert isFemale(rWoman) && 
            age(rWoman) >= parameters.minPregnancyAge && 
            age(rWoman) <= parameters.maxPregnancyAge
    end # checkassumption

    (curryear,currmonth) = date2yearsmonths(Rational(currstep))
    currmonth = currmonth + 1   # adjusting 0:11 => 1:12 
    
    #=
    womanClassShares = []
    womanClassShares.append(len([x for x in womenOfReproductiveAge if x.classRank == 0])/float(len(womenOfReproductiveAge)))
    womanClassShares.append(len([x for x in womenOfReproductiveAge if x.classRank == 1])/float(len(womenOfReproductiveAge)))
    womanClassShares.append(len([x for x in womenOfReproductiveAge if x.classRank == 2])/float(len(womenOfReproductiveAge)))
    womanClassShares.append(len([x for x in womenOfReproductiveAge if x.classRank == 3])/float(len(womenOfReproductiveAge)))
    womanClassShares.append(len([x for x in womenOfReproductiveAge if x.classRank == 4])/float(len(womenOfReproductiveAge)))
    =#


    if curryear < 1951
        rawRate = parameters.growingPopBirthProb
    else
        (yearold,tmp) = date2yearsmonths(age(rWoman)) 
        rawRate = data.fertility[yearold-16,curryear-1950]
    end 

    #=
    a = 0
    for i in range(int(self.p['numberClasses'])):
        a += womanClassShares[i]*math.pow(self.p['fertilityBias'], i)
    baseRate = rawRate/a
    birthProb = baseRate*math.pow(self.p['fertilityBias'], womanRank)
    =#

    # The above formula with one single socio-economic class translates to: 

    birthProb = rawRate * parameters.fertilityBias 
    return birthProb
end

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

    # TODO Assumptions 
    if checkassumption
        for person in people  
            @assert alive(person) 
        end
    end 

    babies = Person[] 
    numBirths =  0    # instead of [0, 0, 0, 0, 0]

    # TODO The following could be collapsed into one loop / not sure if it is more efficient 
    #      there is also a potential to save alot of re-computation in each iteration by 
    #      storing the intermediate results and modifying the computation.
    #      However, it could be also the case that Julia compiler does something efficient any way? 

    allFemales = [ female for female in people if isFemale(female) ]
    adultWomen = [ aWomen for aWomen in allFemales if 
                        age(aWomen) >= parameters.minPregnancyAge ] 
    notFertiledWomen = [ nfWoman for nfWoman in adultWomen if 
                            age(nfWoman) > parameters.maxPregnancyAge ]
    womenOfReproductiveAge = [ rWoman for rWoman in adultWomen if 
                                age(rWoman) <= parameters.maxPregnancyAge ]
    marriedWomenOfReproductiveAge = 
                            [ rmWoman for rmWoman in womenOfReproductiveAge if 
                                !isSingle(rmWoman) ]
    womenWithRecentChild = [rcWoman for rcWoman in adultWomen if 
                                ageYoungestAliveChild(rcWoman) <= 1 ]
    reproductiveWomen = [rWoman for rWoman in marriedWomenOfReproductiveAge if 
                                ageYoungestAliveChild(rWoman) > 1 ] 
    womenOfReproductiveAgeButNotMarried = 
                            [ rnmWoman for rnmWoman in womenOfReproductiveAge if 
                                isSingle(rnmWoman) ]

    # TODO @assumption 
    if checkassumption
        nonadultFemale = setdiff(Set(allFemales),Set(adultWomen)) 
        for female in nonadultFemale
            @assert(isSingle(female))   
            @assert !hasChildren(female) 
        end

        for female in allFemales 
            if female ∉ reproductiveWomen
                @assert isSingle(female) || 
                        age(female) < parameters.minPregnancyAge ||
                        age(female) > parameters.maxPregnancyAge  ||
                        ageYoungestAliveChild(female) <= 1
            end
        end
    end

    #        for person in self.pop.livingPeople:
    #           
    #            if person.sex == 'female' and person.age >= self.p['minPregnancyAge']:
    #                adultLadies += 1
    #                if person.partner != None:
    #                    marriedLadies += 1
    #        marriedPercentage = float(marriedLadies)/float(adultLadies)

    numMarriedRepLadies = length(womenOfReproductiveAge) - length(womenOfReproductiveAgeButNotMarried) 
    repMarriedPercentage = numMarriedRepLadies / length(adultWomen)
    womenWithRecentChildPercentage = length(womenWithRecentChild) / numMarriedRepLadies

    if verbose

        # To do this generic print msg to be placed in a top function 
        println("In iteration $curryear , month $currmonth :")

        println("# allFemales    : $(length(allFemales))") 
        println("# adult women   : $(length(adultWomen))") 
        println("# NotFertile    : $(length(notFertiledWomen))")
        println("# fertile women : $(length(womenOfReproductiveAge))")
        println("# non-married fertile women : $(length(womenOfReproductiveAgeButNotMarried))")
        println("# of women with recent child: $(length(womenWithRecentChild))")
        println("married reproductive percentage : $repMarriedPercentage")
        println("  out of which had a recent child : $womenWithRecentChildPercentage ")

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
        
    for woman in reproductiveWomen 

        if checkassumption
            @assert ageYoungestAliveChild(woman) > 1 
            @assert !isSingle(woman)
            @assert age(woman) >= parameters.minPregnancyAge 
            @assert age(woman) <= parameters.maxPregnancyAge 
        end

        # womanClassRank = woman.classRank
        # if woman.status == 'student':
        #     womanClassRank = woman.parentsClassRank
        
        birthProb = computeBirthProb(woman, parameters, data, currstep,
                                     verbose, sleeptime, checkassumption)

        birthProb <= 0 ? error("birth probabiliy : $birthProb is negative ") : nothing 
        
        #=
        The following code is commented in the python code: 
        #baseRate = self.baseRate(self.socialClassShares, self.p['fertilityBias'], rawRate)
        #fertilityCorrector = (self.socialClassShares[woman.classRank] - self.p['initialClassShares'][woman.classRank])/self.p['initialClassShares'][woman.classRank]
        #baseRate *= 1/math.exp(self.p['fertilityCorrector']*fertilityCorrector)
        #birthProb = baseRate*math.pow(self.p['fertilityBias'], woman.classRank)
        =#

        if rand() < birthProb && rand(1:12) == currmonth 

            # parentsClassRank = max([woman.classRank, woman.partner.classRank])
            # baby = Person(woman, woman.partner, self.year, 0, 'random', woman.house, woman.sec, -1, 
            #              parentsClassRank, 0, 0, 0, 0, 0, 0, 'child', False, 0, month)

            baby = Person(pos=woman.pos,father=partner(woman),mother=woman,gender=rand([male,female]))
            push!(babies,baby) 
            # woman.maternityStatus = True

            #=
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
            =# 
        end # if rand()
    end # for woman 

    if verbose
        println("number of births : $length(babies)")
        sleep(sleeptime)
    end

    return (newbabies=babies)

end  # function doBirths! 


function doAgeTransitions!(people, step, pars)
    
    (year,month) = date2yearsmonths(step)
    month += 1 # adjusting 0:11 => 1:12 

    for person in people

        @assert alive(person)

        if isInMaternity(person)
            # count maternity months
            stepMaternity!(person)

            # end of maternity leave
            if maternityDuration(person) >= pars.maternityLeaveDuration
                resetMaternity!(person)
            end
        end

        agestep!(person)

        # TODO part of location module, TBD
        #if hasBirthday(person, month)
        #    person.movedThisYear = false
        #    person.yearInTown += 1
        #end
    end # person in people

    # only process those not retired and born in the current month
    relevant = I.filter(people) do p
        status(p) != Work.retired && hasBirthday(p, month)
    end

    for person in relevant
        if age(person) == pars.ageTeenagers
            status!(person, Work.teenager)
            continue
        end

        if age(person) == pars.ageOfAdulthood
            status!(person, Work.student)
            class!(person, 0)

            if rand() < pars.probOutOfTownStudent
                outOfTownStudent!(person, true)
            end

            continue
        end

        if age(person) == pars.ageOfRetirement
            status!(person, Work.retired)
            setEmptyJobSchedule!(person)
            wage!(person, 0)

            shareWorkingTime = workingPeriods(person) / pars.minContributionPeriods

            dK = rand(Normal(0, pars.wageVar))
            pension!(person, shareWorkingTime * exp(dK))
        end
    end # for person in non-retired

end


# class sensitive versions
# TODO 
# * move to separate, optional module
# * replace with non-class version here
initialIncomeLevel(person, pars) = pars.incomeInitialLevels[classRank(person)]

workingAge(person, pars) = pars.workingAge[classRank(p)]

function incomeDist(person, pars)
    # TODO make parameters
    if classRank(person) == 0
        LogNormal(2.5, 0.25)
    elseif classRank(person) == 1
        LogNormal(2.8, 0.3)
    elseif classRank(person) == 2
        LogNormal(3.2, 0.35)
    elseif classRank(person) == 3
        LogNormal(3.7, 0.4)
    elseif classRank(person) == 4
        LogNormal(4.5, 0.5)
    else
        error("unknown class rank!")
    end
end

function studyClassFactor(person, model, pars)
    if classRank(person) == 0 
        return socialClassShares(model, 0) > 0.2 ?  1/0.9 : 0.85
    end

    if classRank(person) == 1 && socialClassShares(model, 1) > 0.35
        return 1/0.8
    end

    if classRank(person) == 2 && socialClassShares(model, 2) > 0.25
        return 1/0.85
    end

    1.0
end

doneStudying(person, pars) = classRank(person) >= 4

# move newly adult agents into study or work
function doSocialTransition(people, year, model, pars)
    (year,month) = date2yearsmonths(step)
    month += 1 # adjusting 0:11 => 1:12 

    # newly adult people
    newAdults = I.filter(people) do p
        hasBirthday(p, month) && 
        age(p) == workingAge(person, pars) &&
        status(p) == student
    end

    for person in newAdults
        probStudy = doneStudying(person, pars)  ?  
            0.0 : startStudyProb(person, model, pars)

        if rand() < probStudy
            startStudying!(person, pars)
        else
            startWorking!(person)
            addToWorkforce!(person, model)
        end
    end
end

# probability to start studying instead of working
function startStudyProb(person, model, pars)
    if !alive(father(person)) && !alive(mother(person))
        return 0.0
    end

    perCapitaDisposableIncome = disposableIncomePerCapita(person)

    if perCapitaDisposableIncome <= 0
        return 0.0
    end

    forgoneSalary = initialIncome(person, pars) * 
        pars.weeklyHours[careNeedLevel(person)]
    relCost = forgoneSalary / perCapitaDisposableIncome
    incomeEffect = (pars.constantIncomeParam+1) / 
        (exp(pars.eduWageSensitivity * relCost) + pars.constantIncomeParam)

    # TODO class
    targetEL = max(classRank(father(person)), classRank(mother(person)))
    dE = targetEL - classRank(person)
    expEdu = exp(pars.eduRankSensitivity * dE)
    educationEffect = expEdu / (expEdu + pars.constantEduParam)

    careEffect = 1/exp(pars.careEducationParam * (socialWork(person) + childWork(person)))

    pStudy = incomeEffect * educationEffect * careEffect

    pStudy *= studyClassFactor(person, model, pars)

    return max(0.0, pStudy)
end

function startStudying!(person, pars)
    addClassRank!(person, 1) 
end

function startWorking!(person, pars)

    # TODO think about how to do this
    # part of the model logic, so should be e.g. in person 
    resetWork!(person)

    dKi = rand(Normal(0, pars.wageVar))
    setInitialIncome!(person, initialIncomeLevel(person, pars) * exp(dKi))

    dist = incomeDist(person, pars)

    setFinalIncome!(person, rand(dist))
end


"This function is supposed to implement the suggested model, TODO"
function doBirthsOpt() end

end # module Simulate 
