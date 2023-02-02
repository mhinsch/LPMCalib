export relocate!, selectRelocate


selectRelocate(person, pars) = canLiveAlone(person) && status(person) == WorkStatus.worker && 
    isSingle(person) && livesInSharedHouse(person)

function relocate!(person, time, model, pars)
    if rand() < pars.moveOutProb
        peopleToMove = [person]
        for dep in dependents(person)
            if livingTogether(person, dep)
                push!(peopleToMove, dep)
            end
        end
        
        movePeopleToEmptyHouse!(peopleToMove, rand([:near, :far]), model.houses, model.towns)
        
        return true
    end
    
    false
end
