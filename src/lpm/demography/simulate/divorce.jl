export doDivorces!

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
function manSubjectToDivorce!(man,allHouses,allTowns,parameters,data,time;
                                verbose,sleeptime,checkassumption)
        
    (curryear,currmonth) = date2yearsmonths(time)
    currmonth += 1 # adjusting 0:11 => 1:12
                                
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

    if rand() < divorceProb && rand(1:12) == currmonth
        resolvePartnership!(man, partner(man))
        
        #=
        man.yearDivorced.append(self.year)
        wife.yearDivorced.append(self.year)
        if wife.status == 'student':
            wife.independentStatus = True
            self.startWorking(wife)
        =# 

        attachedChildren = Person[]
        for child in children(person)
            if !alive(child) continue end 
            if father(child) == man && mother(child) != partner(man)
                append!(attachedChildren,child)
            else 
                if rand() < parameters.probChildrenWithFather
                    append!(attachedChildren,child)
                end
            end 
        end # for 

        allocatePeopleToNewHouse(man,attachedChildren,allHouses,
                                    rand(["near", "far"]), allTowns)

        return true 
    end

    false 
end 


function doDivorces!(people,allHouses,allTowns;parameters,data,time,
                        verbose=true,sleeptime=0.0,checkassumption=true) 

    marriedMens = [ man for man in people if isMale(man) && !isSingle(man) ]

    divorced = Person[] 
    
    for man in marriedMens 
        if manSubjectToDivorce!(man, allHouses, allTowns, 
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
