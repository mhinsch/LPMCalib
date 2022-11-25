using Utilities

using XAgents

export selectBirth, doBirths!, birth!

function computeBirthProb(rWoman,parameters,data,currstep)

    (curryear,currmonth) = date2yearsmonths(currstep)
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
        (yearold,tmp) = age2yearsmonths(age(rWoman)) 
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
end # computeBirthProb


function effectsOfMaternity!(woman, pars)
    startMaternity!(woman)
    
    workingHours!(woman, 0)
    income!(woman, 0)
    potentialIncome!(woman, 0)
    availableWorkingHours!(woman, 0)
    # commented in sim.py:
    # woman.weeklyTime = [[0]*12+[1]*12, [0]*12+[1]*12, [0]*12+[1]*12, [0]*12+[1]*12, [0]*12+[1]*12, [0]*12+[1]*12, [0]*12+[1]*12]
    # sets all weeklyTime slots to 1
    # TODO copied from the python code, but does it make sense?
    setFullWeeklyTime!(woman)
    #= TODO
    woman.maxWeeklySupplies = [0, 0, 0, 0]
    woman.residualDailySupplies = [0]*7
    woman.residualWeeklySupplies = [x for x in woman.maxWeeklySupplies]
    =# 

    # TODO not necessarily true in many cases
    if provider(woman) == nothing
        setAsProviderProvidee!(partner(woman), woman)
    end

    nothing
end


function birth!(woman, currstep, data, parameters)

    # womanClassRank = woman.classRank
    # if woman.status == 'student':
    #     womanClassRank = woman.parentsClassRank

    birthProb = computeBirthProb(woman, parameters, data, currstep)
                        
    assumption() do
        @assert isFemale(woman) 
        @assert ageYoungestAliveChild(woman) > 1 
        @assert !isSingle(woman)
        @assert age(woman) >= parameters.minPregnancyAge 
        @assert age(woman) <= parameters.maxPregnancyAge
        @assert birthProb >= 0 
    end
                        
    #=
    The following code is commented in the python code: 
    #baseRate = self.baseRate(self.socialClassShares, self.p['fertilityBias'], rawRate)
    #fertilityCorrector = (self.socialClassShares[woman.classRank] - self.p['initialClassShares'][woman.classRank])/self.p['initialClassShares'][woman.classRank]
    #baseRate *= 1/math.exp(self.p['fertilityCorrector']*fertilityCorrector)
    #birthProb = baseRate*math.pow(self.p['fertilityBias'], woman.classRank)
    =#
                        
    if rand() < p_yearly2monthly(birthProb) 
                        
        # parentsClassRank = max([woman.classRank, woman.partner.classRank])
        # baby = Person(woman, woman.partner, self.year, 0, 'random', woman.house, woman.sec, -1, 
        #              parentsClassRank, 0, 0, 0, 0, 0, 0, 'child', False, 0, month)
                        
        baby = Person(pos=woman.pos,
                        father=partner(woman),mother=woman,
                        gender=rand([male,female]))

        # this goes first, so that we know material circumstances
        effectsOfMaternity!(woman, parameters)
        
        setAsGuardianDependent!(woman, baby)
        if !isSingle(woman) # currently not an option
            setAsGuardianDependent!(partner(woman), baby)
        end
        setAsProviderProvidee!(woman, baby)

        return baby
    end # if rand()

    nothing 
end

function verboseBirthCounting(people,parameters) 

    allFemales = [ woman for woman in people if isFemale(woman) ]
    adultWomen = [ aWoman for aWoman in allFemales if 
                                age(aWoman) >= parameters.minPregnancyAge ] 
    notFertiledWomen = [ nfWoman for nfWoman in adultWomen if 
                                age(nfWoman) > parameters.maxPregnancyAge ]
    womenOfReproductiveAge = [ rWoman for rWoman in adultWomen if 
                                age(rWoman) <= parameters.maxPregnancyAge ]
    marriedWomenOfReproductiveAge = 
                    [ rmWoman for rmWoman in womenOfReproductiveAge if 
                                !isSingle(rmWoman) ]
    womenWithRecentChild = [ rcWoman for rcWoman in adultWomen if 
                                ageYoungestAliveChild(rcWoman) <= 1 ]
    reproductiveWomen = [ rWoman for rWoman in marriedWomenOfReproductiveAge if 
                                ageYoungestAliveChild(rWoman) > 1 ] 
    womenOfReproductiveAgeButNotMarried = 
                    [ rnmWoman for rnmWoman in womenOfReproductiveAge if 
                                isSingle(rnmWoman) ]

        #   for person in self.pop.livingPeople:
    #           
    #      if person.sex == 'female' and person.age >= self.p['minPregnancyAge']:
    #                adultLadies += 1
    #                if person.partner != None:
    #                    marriedLadies += 1
    #        marriedPercentage = float(marriedLadies)/float(adultLadies)

    numMarriedRepLadies = length(womenOfReproductiveAge) - 
                            length(womenOfReproductiveAgeButNotMarried) 
    repMarriedPercentage = numMarriedRepLadies / length(adultWomen)
    womenWithRecentChildPercentage = length(womenWithRecentChild) / numMarriedRepLadies

    println("# allFemales    : $(length(allFemales))") 
    println("# adult women   : $(length(adultWomen))") 
    println("# NotFertile    : $(length(notFertiledWomen))")
    println("# fertile women : $(length(womenOfReproductiveAge))")
    println("# non-married fertile women : $(length(womenOfReproductiveAgeButNotMarried))")
    println("# of women with recent child: $(length(womenWithRecentChild))")
    println("married reproductive percentage : $repMarriedPercentage")
    println("  out of which had a recent child : $womenWithRecentChildPercentage ")

    nothing 
end
"""
Accept a population and evaluates the birth rate upon computing
- the population of married fertile women according to 
fixed parameters (minPregnenacyAge, maxPregnenacyAge) and 
- the birth probability data (fertility bias and growth rates) 

Class rankes and shares are temporarily ignored.
"""

selectBirth(woman, parameters) = isFemale(woman) && 
    !isSingle(woman) && 
    age(woman) >= parameters.minPregnancyAge && 
    age(woman) <= parameters.maxPregnancyAge && 
    ageYoungestAliveChild(woman) > 1 


function doBirths!(people, currstep, data, parameters)

    assumption() do
        for person in people  
            @assert alive(person) 
        end
    end 

    babies = Person[] 
    # numBirths =  0    # instead of [0, 0, 0, 0, 0]

    # TODO The following could be collapsed into one loop / not sure if it is more efficient 
    #      there is also a potential to save alot of re-computation in each iteration by 
    #      storing the intermediate results and modifying the computation.
    #      However, it could be also the case that Julia compiler does something efficient any way? 

    reproductiveWomen = [ woman for woman in people if selectBirth(woman, parameters) ]

    # TODO @assumption 
    assumption() do
        allFemales = [ woman for woman in people if isFemale(woman) ]
        adultWomen = [ aWomen for aWomen in allFemales if 
                         age(aWomen) >= parameters.minPregnancyAge ] 
        nonadultFemale = setdiff(Set(allFemales),Set(adultWomen)) 
        for woman in nonadultFemale
            @assert(isSingle(woman))   
            @assert !hasChildren(woman) 
        end

        for woman in allFemales 
            if woman ∉ reproductiveWomen
                @assert isSingle(woman) || 
                age(woman) < parameters.minPregnancyAge ||
                age(woman) > parameters.maxPregnancyAge  ||
                ageYoungestAliveChild(woman) <= 1
            end
        end
    end

    delayedVerbose() do
        (curryear,currmonth) = date2yearsmonths(currstep)
        currmonth += 1   # adjusting 0:11 => 1:12 
                                
        # TODO this generic print msg to be placed in a top function 
        println("In iteration $curryear , month $currmonth :")
        verboseBirthCounting(people,parameters)
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

        baby = birth!(woman, currstep, data, parameters)
        if baby != nothing 
            push!(babies,baby)
        end 
       
    end # for woman 

    delayedVerbose() do
        println("number of births : $length(babies)")
    end

    # any reason for that?
#    return (newbabies=babies)
    
    babies
end  # function doBirths! 

"This function is supposed to implement the suggested model, TODO"
function doBirthsOpt() end

# the following accessory functions to be moved to an internal module 
population(model)    = model.pop      
data(model)          = model 
alivePeople(model)   = Iterators.filter(a->alive(a), population(model))  
birthPars(pars)      = pars.birthpars                             

# Generic API for doDeaths!
doBirths!(model,time,parameters) = 
    doBirths!(alivePeople(model),time,data(model),birthPars(parameters))





