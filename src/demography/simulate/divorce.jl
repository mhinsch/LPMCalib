export selectDivorce, divorce!

function divorceProbability(rawRate, classRank, model, pars) 
    a = 0
    for i in 1:length(pars.cumProbClasses)
        c = i - 1 # class is 0-based!
        a += socialClassShares(model, c) * pars.divorceBias^(c)
    end
    baseRate = rawRate/a
    baseRate * pars.divorceBias^classRank
end 


function divorce!(man, time, model, parameters)
    agem = age(man) 
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

    divorceProb = divorceProbability(rawRate, classRank(man), model, parameters)

    if rand() < p_yearly2monthly(divorceProb) 
        wife = partner(man)
        resolvePartnership!(man, wife)
        
        #=
        man.yearDivorced.append(self.year)
        wife.yearDivorced.append(self.year)
        =# 
        if status(wife) == WorkStatus.student
            startWorking!(wife, parameters)
        end

        peopleToMove = [man]
        for child in dependents(man)
            @assert alive(child)
            if (father(child) == man && mother(child) != wife) ||
                # if both have the same status decide by probability
                (((father(child) == man) == (mother(child) == wife)) &&
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


selectDivorce(person, pars) = alive(person) && isMale(person) && !isSingle(person)


