module HousingIM
    

using Utilities
using BasicInfoAM
using BasicHouseAM

export moveToHouse!, resetHouse!, livingTogether


"Associate a house to a person, removes person from previous house"
function moveToHouse!(person, house)
    if ! isUndefined(person.pos) 
        removeOccupant!(person.pos, person)
    end

    person.pos = house
    addOccupant!(house, person)
end

"reset house of a person (e.g. became dead)"
function resetHouse!(person) 
    if ! isUndefined(person.pos) 
        removeOccupant!(person.pos, person)
    end

    person.pos = undefined(person.pos)
    nothing 
end 


livingTogether(person1, person2) = person1.pos == person2.pos


end
