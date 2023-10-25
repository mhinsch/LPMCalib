using Utilities

export selectBirth, birth! 

isFertileWoman(p, pars) = isFemale(p) && pars.minPregnancyAge <= p.age <= pars.maxPregnancyAge
canBePregnant(p) = !isSingle(p) && ageYoungestAliveChild(p) > 1
isPotentialMother(p, pars) = isFertileWoman(p, pars) && canBePregnant(p)

mutable struct BirthCache{PERSON}
    potentialMothers :: Vector{PERSON}
    pPotentialMotherInFertWAndAge :: Vector{Float64}
    classBias :: Vector{Float64}
    nChBias :: Matrix{Float64}
end

BirthCache{T}() where {T} = BirthCache(T[], Float64[], Float64[], zeros(5, 5))

function birthPreCalc!(model, pars)
    pc = model.birthCache
    empty!(pc.potentialMothers)
    for a in model.pop
        if isPotentialMother(a, pars)
            push!(pc.potentialMothers, a)
        end
    end
    
    resize!(pc.pPotentialMotherInFertWAndAge, 150)
    fill!(pc.pPotentialMotherInFertWAndAge, 0)
    cbp = zeros(Int, 150)
    for a in model.pop
        if isFertileWoman(a, pars)
            years = yearsold(a)
            cbp[years] += 1
            if canBePregnant(a)
                pc.pPotentialMotherInFertWAndAge[years] += 1
            end
        end
    end
    for (i, n) in enumerate(cbp)
        pc.pPotentialMotherInFertWAndAge[i] /= n > 0 ? n : Inf 
    end
    
    nPerClass = zeros(5)
    for p in pc.potentialMothers
        nPerClass[p.classRank+1] += 1
    end
    
    pcpm = copy(nPerClass)
    if length(pc.potentialMothers) > 0
        pcpm ./= length(pc.potentialMothers)
    end
    resize!(pc.classBias, 5)
    preCalcRateBias!(c->pcpm[c+1], 0:4, pars.fertilityBias, pc.classBias, 1)
    
    pncpmc = zeros(5, 5)
    for p in pc.potentialMothers
        c = p.classRank
        nc = min(4, nChildren(p))
        pncpmc[c+1, nc+1] += 1
    end
    
    fill!(pc.nChBias, 0.0)
    for class in 0:4
        for n in 0:4
            pncpmc[class+1, n+1] /= nPerClass[class+1]
        end
        preCalcRateBias!(n -> pncpmc[class+1, n+1], 0:4, pars.prevChildFertBias, 
            view(pc.nChBias, class+1, :), 1)
    end
end

"Proportion of women that can get pregnant in entire population."
function pPotentialMotherInAllPop(model, pars)
    n = length(model.birthCache.potentialMothers)
    
    n / length(model.pop)
end


function computeBirthProb(woman, parameters, model, currstep)
    (curryear,currmonth) = date2yearsmonths(currstep)
    currmonth = currmonth + 1   # adjusting 0:11 => 1:12 

    womanRank = woman.classRank
    if woman.status == WorkStatus.student
        womanRank = woman.parentClassRank
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
            model.birthCache.pPotentialMotherInFertWAndAge[ageYears]
    end 
    
    # fertility bias by class
    birthProb = rawRate * model.birthCache.classBias[womanRank+1] 
        
    # fertility bias by number of previous children
    birthProb *= model.birthCache.nChBias[womanRank+1, min(4,nChildren(woman))+1]
        
    min(1.0, birthProb)
end # computeBirthProb


function effectsOfMaternity!(woman, pars)
    startMaternity!(woman)
    
    woman.workingHours = 0
    woman.income = 0
    woman.availableWorkingHours = 0

    # TODO not necessarily true in many cases
    if woman.provider == undefinedPerson
        setAsProviderProvidee!(woman.partner, woman)
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
        @assert woman.age >= parameters.minPregnancyAge 
        @assert woman.age <= parameters.maxPregnancyAge
        @assert birthProb >= 0 
    end
                        
    #=
    The following code is commented in the python code: 
    #baseRate = self.baseRate(self.socialClassShares, self.p['fertilityBias'], rawRate)
    #fertilityCorrector = (self.socialClassShares[woman.classRank] - self.p['initialClassShares'][woman.classRank])/self.p['initialClassShares'][woman.classRank]
    #baseRate *= 1/math.exp(self.p['fertilityCorrector']*fertilityCorrector)
    #birthProb = baseRate*math.pow(self.p['fertilityBias'], woman.classRank)
    =#
                        
    if rand() < p_yearly2monthly(limit(0.0, birthProb, 1.0)) 
                        
        baby = Person(gender=rand([male,female]))
        moveToHouse!(baby, woman.pos)
        setAsParentChild!(baby, woman)
        if !isSingle(woman) # currently not an option
            setAsParentChild!(baby, woman.partner)
        end

        # this goes first, so that we know material circumstances
        effectsOfMaternity!(woman, parameters)
        
        setAsGuardianDependent!(woman, baby)
        if !isSingle(woman) # currently not an option
            setAsGuardianDependent!(woman.partner, baby)
        end
        setAsProviderProvidee!(woman, baby)

        addBaby!(model, baby)
    end # if rand()

    nothing 
end

