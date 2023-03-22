using TypedMemo
using Memoization


using Utilities

export selectBirth, birth!, resetCachesBirth 

isFertileWoman(p, pars) = isFemale(p) && pars.minPregnancyAge <= age(p) <= pars.maxPregnancyAge
canBePregnant(p) = !isSingle(p) && ageYoungestAliveChild(p) > 1
isPotentialMother(p, pars) = isFertileWoman(p, pars) && canBePregnant(p)

#"Proportion of women that can get pregnant in entire population."
@cached Dict () function pPotentialMotherInAllPop(model, pars)
    n = count(p -> isPotentialMother(p, pars), model.pop)
    
    n / length(model.pop)
end
resetCachePPotentialMotherInAllPop() = reset_all_caches!(pPotentialMotherInAllPop)

#"Proportion of women that can be mothers within all reproductive women of a given age."
@cached ArrayDict{@RET()}(150) years function pPotentialMotherInFertWAndAge(model, years, pars)
    nAll, nM = countSubset(p->isFertileWoman(p, pars) && yearsold(p) == years, 
                           canBePregnant, model.pop)

    nAll > 0 ? nM/nAll : 0.0
end
resetCachePPotentialMotherInFertWAndAge() = reset_all_caches!(pPotentialMotherInFertWAndAge)
            
#"Proportion of women of a given class within all reproductive women."
@cached OffsetArrayDict{@RET()}(10, 0) class function pClassInPotentialMothers(model, class, pars)
    nAll, nC = countSubset(p->isPotentialMother(p, pars), p->classRank(p) == class, model.pop)

    nAll > 0 ? nC / nAll : 0.0
end
resetCachePClassInPotentialMothers() = reset_all_caches!(pClassInPotentialMothers)

#"Calculate the percentage of women with a given number of children for a given class."
#@cached OffsetArrayDict{@RET()}((20,10), (0,0)) (nchildren, class) function pNChildrenInPotMotherAndClass(model, nchildren, class, pars)
@cached Dict function pNChildrenInPotMotherAndClass(model, nchildren, class, pars)
#@memoize Dict function pNChildrenInPotMotherAndClass(model, nchildren, class, pars)
    nAll, nnC = countSubset(p->isPotentialMother(p, pars) && classRank(p) == class, 
                            p->min(4, nChildren(p)) == nchildren, model.pop)

    nAll > 0 ? nnC / nAll : 0.0
end
resetCachePNChildrenInPotMotherAndClass() = reset_all_caches!(pNChildrenInPotMotherAndClass)
#resetCachePNChildrenInPotMotherAndClass() = Memoization.empty_cache!(pNChildrenInPotMotherAndClass)


function resetCachesBirth()
    resetCachePClassInPotentialMothers()
    resetCachePPotentialMotherInFertWAndAge()
    resetCachePNChildrenInPotMotherAndClass()
    resetCachePPotentialMotherInAllPop()
end


function computeBirthProb(woman, parameters, model, currstep)
    (curryear,currmonth) = date2yearsmonths(currstep)
    currmonth = currmonth + 1   # adjusting 0:11 => 1:12 

    womanRank = classRank(woman)
    if status(woman) == WorkStatus.student
        womanRank = parentClassRank(woman)
    end
    
    ageYears = yearsold(woman)
    fertAge = ageYears-parameters.minPregnancyAge+1
    
    if curryear < 1951
        # number of children per uk resident and year
        rawRate = model.pre51Fertility[Int(curryear-parameters.startTime+1)] /
            # scale by number of women that can actually get pregnant
            pPotentialMotherInAllPop(model, parameters) * 
            # and multiply with age-specific fertility factor 
            model.fertFByAge51[fertAge]
    else
        # fertility rates are stored as P(pregnant) per year and age
        rawRate = model.fertility[fertAge, curryear-1950] /
            pPotentialMotherInFertWAndAge(model, ageYears, parameters)
    end 
    
    # fertility bias by class
    a = sum(0:(length(parameters.cumProbClasses)-1)) do class
            pClassInPotentialMothers(model, class, parameters) * parameters.fertilityBias^class
        end
    birthProb = rawRate/a * parameters.fertilityBias^womanRank
    
    
    a = 0.0
    for nch in 0:4 
        @noinline a += pNChildrenInPotMotherAndClass(model, nch, womanRank, parameters) * 
        parameters.prevChildFertBias^nch
    end  
    # fertility bias by number of previous children
    #a = sum(0:4) do nch 
    #        pNChildrenInPotMotherAndClass(model, nch, womanRank, parameters) * 
    #            parameters.prevChildFertBias^nch
    #    end  
    #@assert a2 == a
    birthProb = birthProb/a * parameters.prevChildFertBias^min(4, nChildren(woman))
        

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


selectBirth(person, parameters) = isFertileWoman(person, parameters) && !isSingle(person) && 
    ageYoungestAliveChild(person) > 1 


function birth!(woman, currstep, model, parameters, addBaby!)
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

