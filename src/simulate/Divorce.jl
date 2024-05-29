module Divorce
    

using Utilities

using BasicInfoAM, KinshipAM, WorkAM, DemoPerson
using MoveHouse, Social

export selectDivorce, divorce!, divorcePreCalc!
export DivorceCache


mutable struct DivorceCache
    classBias :: Vector{Float64}
end

DivorceCache() = DivorceCache([])


function divorcePreCalc!(model, pars)
    pc = model.divorceCache
    resize!(pc.classBias, 5)
    classes = 0:(length(pars.cumProbClasses)-1)
    preCalcRateBias!(classes, pars.divorceBias, pc.classBias, 1) do c
        model.socialCache.socialClassShares[c+1]
    end
end
    

function divorceProbability(rawRate, classRank, model, pars) 
    rawRate * model.divorceCache.classBias[classRank+1]#=rateBias(0:(length(pars.cumProbClasses)-1), pars.divorceBias, classRank) do c
        model.socialCache.socialClassShares[c+1]
    end=#
end 


function divorce!(man, time, model, parameters)
    agem = man.age 
    assumption() do
        @assert isMale(man) 
        @assert !isSingle(man)
        @assert typeof(agem) == Rational{Int}
    end
    
    ## This is here to manage the sweeping through of this parameter
    ## but only for the years after 2012
    if time < parameters.thePresent 
        # Not sure yet if the following is parameter or data 
        rawRate = parameters.basicDivorceRate * parameters.divorceModifierByDecade[ceil(Int, agem / 10)]
    else 
        rawRate = parameters.variableDivorce  * parameters.divorceModifierByDecade[ceil(Int, agem / 10)]           
    end

    divorceProb = divorceProbability(rawRate, man.classRank, model, parameters)

    if rand() < p_yearly2monthly(limit(0.0, divorceProb, 1.0)) 
        wife = man.partner
        resolvePartnership!(man, wife)
        
        #=
        man.yearDivorced.append(self.year)
        wife.yearDivorced.append(self.year)
        =# 
        if wife.status == WorkStatus.student
            studentStartWorking!(wife, parameters)
        end

        peopleToMove = [man]
        for child in man.dependents
            @assert child.alive
            if (child.father == man && child.mother != wife) ||
                # if both have the same status decide by probability
                (((child.father == man) == (child.mother == wife)) &&
                 rand() < parameters.probChildrenWithFather)
                push!(peopleToMove, child)
                resolveDependency!(wife, child)
            else
                resolveDependency!(man, child)
            end 
        end # for 

        movePeopleToEmptyHouse!(peopleToMove, rand([:near, :far]), model.houses, model.towns)

        return true 
    end

    false 
end 


selectDivorce(person, pars) = person.alive && isMale(person) && !isSingle(person)


end
