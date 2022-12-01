using Memoization


using Utilities

export selectBirth, birth!, 
    reprWomenSocialClassShares, resetCacheReprWomenSocialClassShares,
    marriedPercentage, resetCacheMarriedPercentage


isReprWoman(p) = isFemale(p) && pars.minPregnancyAge <= age(p) <= pars.maxPregnancyAge


# TODO should this be here?
@memoize Dict function reprWomenSocialClassShares(model, class, pars)

    nAll, nC = countSubset(isReprWoman, p->classRank(p) == class, model.pop)

    nAll > 0 ? nC / nAll : 0.0
end
resetCacheReprWomenSocialClassShares() = Memoization.empty_cache!(reprWomenSocialClassShares)


@memoize Dict function marriedPercentage(model, class, pars)
    nAll, nM = countSubset(p->isReprWoman(p) && classRank(p) == class, 
                           p->!isSingle(p), model.pop)

    nAll > 0 ? nM/nAll : 0.0
end
resetCacheMarriedPercentage() = Memoization.empty_cache!(marriedPercentage)
            
"Calculate the percentage of women with a given number of children for a given class."
@memoize Dict function nChildrenPercentageByClass(model, nchildren, class, pars)
    nAll, nnC = countSubset(p->isReprWoman(p) && classRank(p) == class, 
                            p->nChildren(p) == nchildren, model.pop)

    nAll > 0 ? nnC / nAll : 0.0
end
resetCacheNChildrenPercentageByClass() = Memoization.empty_cache!(nChildrenPercentageByClass)


function computeBirthProb(rWoman, parameters, model, currstep)

    (curryear,currmonth) = date2yearsmonths(currstep)
    currmonth = currmonth + 1   # adjusting 0:11 => 1:12 

    womanRank = classRank(rWoman)
    if status(rWoman) == WorkStatus.student
        womanRank = parentClassRank(rWoman)
    end

    if curryear < 1951
        rawRate = parameters.growingPopBirthProb
    else
        (yearold,tmp) = age2yearsmonths(age(rWoman)) 
        # division by mP happens at the very end in python version
        rawRate = model.fertility[yearold-16,curryear-1950] /
            marriedPercentage(model, womanRank, parameters)
    end 

    a = 0
    for i in 1:length(parameters.cumProbClasses)
        c = i - 1 # class is 0-based!
        a += reprWomenSocialClassShares(model, c, parameters) * parameters.fertilityBias^c
    end

    birthProb = rawRate/a * parameters.fertilityBias^womanRank

    min(1.0, birthProb)
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


selectBirth(person, parameters) = isReprWoman(person) && !isSingle(person) && 
    ageYoungestAliveChild(person) > 1 


function birth!(woman, currstep, model, parameters, addBaby!)

    # womanClassRank = woman.classRank
    # if woman.status == 'student':
    #     womanClassRank = woman.parentsClassRank

    birthProb = computeBirthProb(woman, parameters, model, currstep)
                        
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

        addBaby!(model, baby)
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


