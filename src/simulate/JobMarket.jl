module JobMarket
    

using StatsBase
using Distributions


using WorkAM, MaternityAM


export isActive


function assignUnemploymentDuration!(unemployed, uRates, durationShares, pars)
    @assert sum(durationShares) <= 1
    totUnemployed = length(unemployed)
    if totUnemployed == 0
        return nothing
    end
    
    weights = map(unemployed) do x
            ur = uRates[x.classRank+1, ageBand(x.age)+1]
            1.0/exp(pars.unemploymentBeta * ur)
        end
    sampler = WeightSampler(weights)
    
    for (durationIndex, durationShare) in enumerate(durationShares)
        numUnemployed = floor(Int, totUnemployed * durationShare)
        
        for i in 1:numUnemployed
            toAssignIdx = sampleNoReplace!(sampler) 
            person = unemployed[toAssignIdx]
                    
            if durationIndex < 7
                person.unemploymentDuration = durationIndex
            elseif durationIndex == 7
                person.unemploymentDuration = rand(7:10)
            elseif durationIndex == 8
                person.unemploymentDuration = rand(10:13)
            elseif durationIndex == 9
                person.unemploymentDuration = rand(13:19)
            elseif durationIndex == 10
                person.unemploymentDuration = rand(19:25)
            end
        end
    end
    
    for (i,w) in enumerate(weights)
        if w == 0
            unemployed[i].unemploymentDuration = 25
        end
    end

    nothing
end


function assignUnemploymentDurationByGender!(newEntrants, uRates, pars)
    assignUnemploymentDuration!(filter(isMale, newEntrants), uRates, pars.maleUDS, pars)
    assignUnemploymentDuration!(filter(isFemale, newEntrants), uRates, pars.femaleUDS, pars)
end


function dismissWorkers!(newUnemployed, uRates, pars)
    for person in newUnemployed
        loseJob!(person)
        changeStatus!(person, WorkStatus.unemployed, pars)
    end
    
    assignUnemploymentDurationByGender!(newUnemployed, uRates, pars)
end

# TODO generalise, put elsewhere
canWork(person) = person.careNeedLevel < 4 && !isInMaternity(person) 

# Base.zero(::Type{Vector{T}}) where T = T[]
function Matrix{Vector{T}}(sz) where {T}
    m = Matrix{Vector{T}}(undef, sz)
    for c in 1:sz[1], a in 1:sz[2]
        m[c, a] = T[]
    end
    m
end

isActive(person) = (statusWorker(person) || statusUnemployed(person)) && canWork(person)
isWorking(person) = statusWorker(person) && canWork(person)
isUnemployed(person) = statusUnemployed(person) && canWork(person)

function jobMarket!(model, time, pars)
    year, month = date2yearsmonths(time)

    # everyone working or in the job market
    activePop = Iterators.filter(isActive, model.pop)
    # everyone looking for a job
    unemployed = Iterators.filter(isUnemployed, model.pop)
    
    # *** count SES and age bands for active pop
    
    classShares, ageBandShares = calcAgeClassShares(activePop, pars)
    
    # *** unemployment rate and index
    
    unemploymentRate = model.unemploymentSeries[floor(Int, year + (pars.startTime-1860)) + 1]
    uRates = computeURByClassAge(unemploymentRate, classShares, ageBandShares, pars)         
    
    # people entering the jobmarket need waiting time calculated 
    newEntrants = [x for x in unemployed if x.newEntrant]
    assignUnemploymentDurationByGender!(newEntrants, uRates, pars)
    
    # *** update tenure etc. for working population
    # *** and unemployment times for unemployed
    for person in activePop
        if isWorking(person)
            person.jobTenure += 1
            if person.workingHours > 0
                person.workingPeriods += person.availableWorkingHours/person.workingHours
            end
            person.workExperience += person.availableWorkingHours/pars.weeklyHours[1]
            person.wage = computeWage(person, pars)
        else
            person.unemploymentMonths += 1
            person.unemploymentDuration -= 1
        end
    end
    
    PType = eltype(model.pop)
    # for some reason this is vastly slower
    #acActivePopM = zeros(Vector{PType}, size(ageBandShares))
    acActivePop = Matrix{Vector{PType}}(size(ageBandShares))
    
    for p in activePop
        push!(acActivePop[p.classRank+1, ageBand(p.age)+1], p)
    end
    
    adjustJobsByAgeAndClass!(acActivePop, uRates, unemploymentRate, month, model, pars)
end


function adjustJobsByAgeAndClass!(acActivePopM, uRates, unemploymentRate, month, 
    model, pars)
    PType = eltype(model.pop)
    actualUnemployed = PType[]
    employedWorkers = PType[]
    dismissedWorkers = PType[]
    sampler = WeightSampler(Float64[])
    for c in 0:size(acActivePopM)[1]-1, a in 0:size(acActivePopM)[2]-1
        acActivePop = acActivePopM[c+1, a+1]
        if isempty(acActivePop) continue end
            
        empty!(actualUnemployed)
        empty!(employedWorkers)
        for p in acActivePop
            if statusWorker(p)
                push!(employedWorkers, p)
            else
                push!(actualUnemployed, p)
            end
        end
        
        ageSES_ur = uRates[c+1, a+1]
        
        # *** regular job losses due to turnover
        
        if length(employedWorkers) > 0
            resetSampler!(sampler, length(employedWorkers))
            nDismissable = 0
            for (i, p) in enumerate(employedWorkers)
                if p.jobTenure >= pars.probationPeriod
                    initWeight!(sampler, i, 1.0 / exp(pars.layOffsBeta * p.jobTenure)) 
                    nDismissable += 1
                else
                    initWeight!(sampler, i, 0.0)
                end
            end
            
            # layoffs happen at a constant rate that is modified by class/age-specific UR
            layOffsRate = pars.meanLayOffsRate * ageSES_ur/unemploymentRate
            numLayOffs = min(floor(Int, length(employedWorkers)*layOffsRate), nDismissable)
            empty!(dismissedWorkers)
                
            for i in 1:numLayOffs
                firedWorkerIdx = sampleNoReplace!(sampler)
                push!(dismissedWorkers, employedWorkers[firedWorkerIdx])
                remove_unsorted!(employedWorkers, firedWorkerIdx)
                remove_unsorted!(sampler.weights, firedWorkerIdx)
            end
            dismissWorkers!(dismissedWorkers, uRates, pars)
            append!(actualUnemployed, dismissedWorkers)
        end
        
        # *** adjust unemployment rate to conform to empirical numbers
        
        nEmpiricalUnemployed = floor(Int, length(acActivePop) * ageSES_ur)
        if length(actualUnemployed) > nEmpiricalUnemployed
            peopleToHire = length(actualUnemployed) - nEmpiricalUnemployed
            # The probability to be hired is inversely proportional to unemployment duration.
            # Order workers from lower to higher duration, and hire from the top.
            # NOTE! unemployment duration == time left in unemployment
            sort!(actualUnemployed, by=x->x.unemploymentDuration)
            resize!(actualUnemployed, peopleToHire)
            assignJobs!(actualUnemployed, model.shiftsPool, month, pars)
        elseif nEmpiricalUnemployed > length(actualUnemployed)
            nPeopleToFire = min(nEmpiricalUnemployed-length(actualUnemployed), length(employedWorkers))
            mapWeights!(sampler, employedWorkers) do p 
                    1.0/exp(pars.layOffsBeta*p.jobTenure)
                end
            firedWorkers = sampleNoReplaceFrom!(sampler, employedWorkers, nPeopleToFire)
            dismissWorkers!(firedWorkers, uRates, pars)
        end
    end
end    


end
