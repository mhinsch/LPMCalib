module HousingTopDown


using Utilities

using DependenciesAM, DemoHouse


export houseOwnership!


function houseOwnership!(model, pars)
    houses = model.houses
    
    households = filter(isOccupied, houses)
    # Compute household's income decile
    sort!(households, by=x->x.householdIncome)
    for (i, h) in enumerate(households)
        h.incomeDecile = floor(Int, (i-1)/length(households) * 10)
    end
    
    # TODO: this might need rethinking. What about shared flats, adult and earning children,
    # grandparents living in house, etc.?
    for house in households
        n = 0
        age = 0
        for agent in Iterators.filter(x->!isDependent(x), house.occupants)
            n += 1
            age += agent.age
            # not currently the case!
            #@assert (isSingle(agent) && n<2) || 
            #    (!isSingle(agent) && livingTogether(agent, agent.partner))
        end
        #@assert 1<=n<=2
        
        # average age of independent occupants
        house.ageOccupants = age / n
    end
    
    housesByAge = [eltype(houses)[] for i in 1:length(pars.ageOwnershipShares)]
    # Check number of owned houses in each income-age class
    # iterate through income deciles
    for d in 0:9
        empty!.(housesByAge)
        # sort households in decile d by age class
        for h in Iterators.filter(h->h.incomeDecile == d, households)
            push!(housesByAge[searchsortedfirst(pars.HOAgeRanges, h.ageOccupants)], h)
        end
        # iterate age classes
        for (a, ageHouse) in enumerate(housesByAge)
            # how many people should own their house in this age class
            share = pars.ageOwnershipShares[a]
            
            nEmpiricalOwners = floor(Int, share * length(ageHouse))
            ownedHouses, rentedHouses = separate(x->x.ownedByOccupants, ageHouse)
            if nEmpiricalOwners < length(ownedHouses)
                # In this case some house are sold
                numHousesToSell = length(ownedHouses) - nEmpiricalOwners
                # TODO: add ownership index
                weights = [1.0/exp(pars.ownershipProbExp * 1#=x.ownershipIndex=#) for x in ownedHouses]
                sampler = WeightSampler(weights)
                for i in numHousesToSell
                    idx = sampleNoReplace!(sampler)
                    ownedHouses[idx].ownedByOccupants = false
                end
            elseif nEmpiricalOwners > length(ownedHouses)
                # In this case, some renting agents by a house.
                numHousesToBuy = nEmpiricalOwners - length(ownedHouses)
                # TODO add ownership index
                weights = [exp(pars.ownershipProbExp * 1#=x.ownershipIndex=#) for x in rentedHouses]
                sampler = WeightSampler(weights)
                for i in numHousesToBuy
                    idx = sampleNoReplace!(sampler)
                    rentedHouses[idx].ownedByOccupants = true
                end
            end
        end
    end
end
                    
                    
function minOwnershipShare(totHouses, pars)
    numByShare = zeros(Int, length(pars.ageOwnershipShares))
    for house in totHouses
        numByShare[searchsortedfirst(pars.ageRanges, house.ageOccupants)] += 1
    end
    
    # calculate expected number of owned houses
    a = 0
    for (i, n) in enumerate(numByShare) 
        a += n * pars.ageOwnershipShares[i] 
    end
    
    # 
    length(totHouses) / a
end


end
