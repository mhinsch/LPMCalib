module Relocate
    

using BasicInfoAM, WorkAM, KinshipAM #, DemoPerson
using HousingIM, DependenciesIM
using MoveHouse

export relocate!, selectRelocate


selectRelocate(person, pars) = canLiveAlone(person) && person.status == WorkStatus.worker && 
    isSingle(person) && livesInSharedHouse(person)

function relocate!(person, time, model, pars)
    if rand() < pars.moveOutProb
        peopleToMove = [person]
        for dep in person.dependents
            if livingTogether(person, dep)
                push!(peopleToMove, dep)
            end
        end
        
        movePeopleToEmptyHouse!(peopleToMove, rand([:near, :far]), model.houses, model.towns)
        
        return true
    end
    
    false
end


end
