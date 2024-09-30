module FamilyIM
    
using Utilities
using BasicInfoAM, KinshipAM

export setAsParentChild!, setAsPartners!, resetPartner!, setParent!
export hasAliveChild, ageYoungestAliveChild, related1stDegree  
export resolvePartnership!, hasOwnChildrenAtHome


related1stDegree(person1, person2) = areParentChild(person1, person2) || areSiblings(person1, person2)

"set the father of a child"
function setAsParentChild!(child, parent) 
    @assert isMale(parent) || isFemale(parent)
    @assert child.age < parent.age
    @assert (isMale(parent) && isUndefined(child.father)) ||
        (isFemale(parent) && isUndefined(child.mother)) 

    addChild!(parent, child)
    setParent!(child, parent) 
    # would be nice to ensure consistency of dependence/provision at this point as well
    # but there are so many specific situations that it is easier to do that in simulation
    # code
    nothing 
end

function resetPartner!(person)
    other = person.partner
    if !isUndefined(other) 
        person.partner = undefined(person.partner)
        person.pTime = 0
        other.partner = undefined(person.partner)
        other.pTime = 0
    end
    nothing 
end

"resolving partnership"
function resolvePartnership!(person1, person2)
    @assert person1.partner == person2 && person2.partner == person1

    resetPartner!(person1)
end


"set two persons to be a partner"
function setAsPartners!(person1, person2)
    @assert isMale(person1) == isFemale(person2)

    resetPartner!(person1) 
    resetPartner!(person2)

    person1.partner = person2
    person2.partner = person1
end


"set child of a parent" 
function setParent!(child, parent)
    @assert isFemale(parent) || isMale(parent)

    if isFemale(parent) 
        child.mother = parent
    else 
        child.father = parent
    end

    nothing
end 

function hasAliveChild(person)
    for child in person.children 
        if child.alive return true end 
    end
    false 
end


function ageYoungestAliveChild(person) 
    youngest = Rational{Int}(Inf)  
    for child in person.children 
        if child.alive 
            youngest = min(youngest,child.age)
        end 
    end
    youngest 
end


function hasOwnChildrenAtHome(person)
    for c in person.children
        if c.alive && c.pos == person.pos
            return true
        end
    end
    
    false
end


end
