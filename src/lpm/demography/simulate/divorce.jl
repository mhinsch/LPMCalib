export doDivorces!, selectDivorce, divorce!

function divorceProbability(rawRate, divorceBias) # ,classRank) 
    #=
     def computeSplitProb(self, rawRate, classRank):
        a = 0
        for i in range(int(self.p['numberClasses'])):
            a += self.socialClassShares[i]*math.pow(self.p['divorceBias'], i)
        baseRate = rawRate/a
        splitProb = baseRate*math.pow(self.p['divorceBias'], classRank)
        return splitProb
    =# 
    rawRate * divorceBias 
end 

# Internal function 
function divorce!(man,allHouses,allTowns,parameters,data,time;
                                verbose,sleeptime,checkassumption)
        
    agem = age(man) 
    if checkassumption 
        @assert isMale(man) 
        @assert !isSingle(man)
        @assert typeof(agem) == Rational{Int}
    end
    
    ## This is here to manage the sweeping through of this parameter
    ## but only for the years after 2012
    if curryear < parameters.thePresent 
        # Not sure yet if the following is parameter or data 
        rawRate = parameters.basicDivorceRate * parameters.divorceModifierByDecade[ceil(Int, agem / 10)]
    else 
        rawRate = parameters.variableDivorce  * parameters.divorceModifierByDecade[ceil(Int, agem / 10)]           
    end

    divorceProb = divorceProbability(rawRate,parameters,data,time) # TODO , man.classRank)

    if rand() < p_yearly2monthly(divorceProb) 
        resolvePartnership!(man, partner(man))
        
        #=
        man.yearDivorced.append(self.year)
        wife.yearDivorced.append(self.year)
        =# 
        if status(wife) == WorkStatus.student
            independent!(wife, true) 
            startWorking!(wife)
        end

        peopleToMove = [man]
        for child in children(person)
            if !alive(child) continue end 
            if father(child) == man && mother(child) != partner(man)
                push!(peopleToMove, child)
            else 
                if rand() < parameters.probChildrenWithFather
                    push!(peopleToMove, child)
                end
            end 
        end # for 

        movePeopleToEmptyHouse!(peopleToMove, rand([:near, :far]), allHouses, allTowns)

        return true 
    end

    false 
end 


selectDivorce(person, pars) = alive(person) && isMale(person) && !isSingle(person)


function doDivorces!(people,allHouses,allTowns;parameters,data,time,
                        verbose=true,sleeptime=0.0,checkassumption=true) 

    marriedMen = [ man for man in people if selectDivorce(man, pars) ]

    divorced = Person[] 
    
    for man in marriedMen 
        if divorce!(man, allHouses, allTowns, 
                                parameters, data, time, 
                                verbose = verbose, 
                                sleeptime = sleeptime, 
                                checkassumption = checkassumption )
            divorced.append!([man, partner(man)]) 
        end 
    end 

    if verbose 
        println("# of divorced in current iteration $(length(divorced))")
        sleeptime(sleeptime)
    end
    
    divorced 
end
