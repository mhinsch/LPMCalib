export doDivorces!, selectDivorce, divorce!

function divorceProbability(rawRate, pars) # ,classRank) 
    #=
     def computeSplitProb(self, rawRate, classRank):
        a = 0
        for i in range(int(self.p['numberClasses'])):
            a += self.socialClassShares[i]*math.pow(self.p['divorceBias'], i)
        baseRate = rawRate/a
        splitProb = baseRate*math.pow(self.p['divorceBias'], classRank)
        return splitProb
    =# 
    rawRate * pars.divorceBias 
end 

function divorce!(man, time, model, parameters)
    applyDivorce!(man, time, model.houses, model.towns, parameters)
end


function applyDivorce!(man, time, allHouses, allTowns, parameters)
        
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

    divorceProb = divorceProbability(rawRate, parameters) # TODO , man.classRank)

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

        movePeopleToEmptyHouse!(peopleToMove, rand([:near, :far]), allHouses, allTowns)

        return true 
    end

    false 
end 


selectDivorce(person, pars) = alive(person) && isMale(person) && !isSingle(person)


function doDivorces!(people, time, model, parameters)

    marriedMen = [ man for man in people if selectDivorce(man, parameters) ]

    divorced = Person[] 
    
    for man in marriedMen 
        if divorce!(man, model, parameters, time) 
            divorced.append!([man, partner(man)]) 
        end 
    end 

    delayedVerbose() do
        println("# of divorced in current iteration $(length(divorced))")
    end
    
    divorced 
end
