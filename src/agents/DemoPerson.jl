module DemoPerson


using CompositeStructs

using Utilities

using Tasks, Towns, DemoHouse

export Person
export PersonHouse, PersonTown, PersonTask 
export undefinedPerson, undefinedHouse 

export moveToHouse!, resetHouse!, livesInSharedHouse, resolvePartnership!, householdIncome
export householdIncomePerCapita

export livingTogether, setAsParentChild!, setAsPartners!, setParent!
export hasAliveChild, ageYoungestAliveChild 
export hasOwnChildrenAtHome, related1stDegree 
export canLiveAlone, isOrphan, setAsGuardianDependent!, setAsProviderProvidee!
export setAsIndependent!, setAsSelfproviding!, resolveDependency!
export checkConsistencyDependents
export maxParentRank
export schoolCare



using InstitutionsAM
using WorkAM, KinshipAM, MaternityAM, BasicInfoAM, CareAM, ClassAM, DependenciesAM, TasksAM
using BenefitsAM


"""
Specification of a Person Agent Type. 
Person ties various agent modules into one compound agent type.
""" 

@composite @kwdef mutable struct Person 
    
    BasicInfo...
    Kinship{Person}...
    Maternity...
    Work...
    Care...
    Class...
    Benefits...
    Dependency{Person}...
    TaskPerson{ATask{Person}}...
    
    pos::House{Person, Town} = undefinedHouse
    # undefined Person
    function Person(::Nothing)
        p = new()
        p.age = -1
        p
    end
    
    # default constructor
    Person(args...) = new(args...)
end # struct Person 

# delegate functions to components
DemoHouse.getHomeTown(person::Person) = getHomeTown(person.pos)

# by convention person objects that are institutions have age == -1
InstitutionsAM.isRealPerson(p) = p.age >= 0


const PersonHouse = House{Person, Town}
const PersonTown = Town{PersonHouse}
const PersonTask = ATask{Person}
const undefinedTown = PersonTown((-1,-1), 0.0)
const undefinedHouse = PersonHouse(undefinedTown, (-1, -1))
const undefinedPerson = Person(nothing)
const undefinedTask = PersonTask(0, undefinedPerson, undefinedPerson, 0, 0, 0)

Utilities.undefined(::T) where {T} = undefinedT(T)
Utilities.undefined(t::DataType) = undefinedT(t)
undefinedT(::Type{PersonHouse}) = undefinedHouse
undefinedT(::Type{PersonTown}) = undefinedTown
undefinedT(::Type{Person}) = undefinedPerson
undefinedT(::Type{PersonTask}) = undefinedTask

Utilities.isUndefined(t::T) where {T} = t == undefined(t) 


const schoolCare = Person(nothing)


"associate a house to a person, removes person from previous house"
function moveToHouse!(person,house)
    if ! isUndefined(person.pos) 
        removeOccupant!(person.pos, person)
    end

    person.pos = house
    addOccupant!(house, person)
end

"reset house of a person (e.g. became dead)"
function resetHouse!(person::Person) 
    if ! isUndefined(person.pos) 
        removeOccupant!(person.pos, person)
    end

    person.pos = undefinedHouse
    nothing 
end 

livingTogether(person1, person2) = person1.pos == person2.pos

"Whether the person shares their house with a non-dependent, non-guardian. Note that this includes spouses and spouses' children."
function livesInSharedHouse(person)
    for p in person.pos.occupants
        if p != person && ! (p in person.guardians) && ! (p in person.dependents)
            return true
        end
    end
    
    false
end


related1stDegree(person1, person2) = areParentChild(person1, person2) || areSiblings(person1, person2)


# TODO check if correct
# TODO cache for optimisation?
householdIncome(person) = sum(p -> p.income, person.pos.occupants)
householdIncomePerCapita(person) = householdIncome(person) / length(person.pos.occupants)


"set the father of a child"
function setAsParentChild!(child::Person,parent::Person) 
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
        person.partner = undefinedPerson
        person.pTime = 0
        other.partner = undefinedPerson
        other.pTime = 0
    end
    nothing 
end

"resolving partnership"
function resolvePartnership!(person1::Person, person2::Person)
    @assert person1.partner == person2 && person2.partner == person1

    resetPartner!(person1)
end


"set two persons to be a partner"
function setAsPartners!(person1::Person,person2::Person)
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

function hasOwnChildrenAtHome(person)
    for c in person.children
        if c.alive && c.pos == person.pos
            return true
        end
    end
    
    false
end


function ageYoungestAliveChild(person::Person) 
    youngest = Rational{Int}(Inf)  
    for child in person.children 
        if child.alive 
            youngest = min(youngest,child.age)
        end 
    end
    youngest 
end


canLiveAlone(person) = person.age >= 18
isOrphan(person) = !canLiveAlone(person) && !isDependent(person)

function setAsGuardianDependent!(guardian, dependent)
    push!(guardian.dependents, dependent)
    push!(dependent.guardians, guardian)

    # set class rank to maximum of guardians'
    dependent.parentClassRank = maximum(x->x.classRank, dependent.guardians)
    nothing
end

function resolveDependency!(guardian, dependent)
    deps = guardian.dependents
    idx_d = findfirst(==(dependent), deps)
    if idx_d == nothing
        return
    end

    deleteat!(deps, idx_d)

    guards = dependent.guardians
    idx_g = findfirst(==(guardian), guards)
    if idx_g == nothing
        error("inconsistent dependency!")
    end
    deleteat!(guards, idx_g)
    nothing
end

"Dissolve all guardian-dependent relationships of `person`"
function setAsIndependent!(person)
    if !isDependent(person) 
        return
    end

    for g in person.guardians
        g_deps = g.dependents
        deleteat!(g_deps, findfirst(==(person), g_deps))
    end
    empty!(person.guardians)
    nothing
end

# check basic consistency, if there's an error on any of these 
# then something is seriously wrong
function checkConsistencyDependents(person)
    for guard in person.guardians
        @assert !isUndefined(guard) && guard.alive
        @assert person in guard.dependents
    end

    for dep in person.dependents
        @assert !isUndefined(dep)  
        @assert dep.age < 18
        @assert person.pos == dep.pos
        @assert person in dep.guardians
    end
end


function setAsProviderProvidee!(prov, providee)
    @assert isUndefined(providee.provider)
    @assert !(providee in prov.providees)
    push!(prov.providees, providee)
    providee.provider = prov
    nothing
end

function setAsSelfproviding!(person)
    if isUndefined(person.provider)
        return
    end

    provs = person.provider.providees
    deleteat!(provs, findfirst(==(person), provs))
    person.provider = undefinedPerson
    nothing
end


function maxParentRank(person)
    f = person.father
    m = person.mother
    if f == m == undefinedPerson
        person.classRank
    elseif f == undefinedPerson
        m.classRank
    elseif m == undefinedPerson
        f.classRank
    else
        max(m.classRank, f.classRank)
    end
end


function howBusyAt(p::Person, hour)
    if p.jobSchedule[hour]
        return 1.0
    end
    
    return p.taskSchedule[hour]
end



function Utilities.dump_header(io, p::Person, FS)
    print(io, "id", FS, "house", FS)
    Utilities.dump_header(io, p.info, FS); print(io, FS)
    Utilities.dump_header(io, p.kinship, FS); print(io, FS)
    Utilities.dump_header(io, p.maternity, FS); print(io, FS)
    Utilities.dump_header(io, p.work, FS); print(io, FS)
    Utilities.dump_header(io, p.care, FS); print(io, FS)
    Utilities.dump_header(io, p.class, FS); print(io, FS)
    Utilities.dump_header(io, p.dependencies, FS)
end

# links to objects are dumped as object id
function Utilities.dump_property(io, prop::Person, FS="\t", ES=",")
    print(io, objectid(prop))
end

function Utilities.dump_property(io, prop::House, FS="\t", ES=",")
    print(io, objectid(prop))
end

function Utilities.dump_property(io, prop::Union{Person, Nothing}, FS="\t", ES=",") 
    if prop == nothing
        print(io, 0)
    else
        Utilities.dump_property(io, prop, FS, ES)
    end
end

function Utilities.dump(io, person::Person, FS="\t", ES=",")
    print(io, objectid(person), FS)
    Utilities.dump_property(io, person.pos, FS, ES); print(io, FS)
    Utilities.dump(io, person.info, FS, ES); print(io, FS)
    Utilities.dump(io, person.kinship, FS, ES); print(io, FS)
    Utilities.dump(io, person.maternity, FS, ES); print(io, FS)
    Utilities.dump(io, person.work, FS, ES); print(io, FS)
    Utilities.dump(io, person.care, FS, ES); print(io, FS)
    Utilities.dump(io, person.class, FS, ES); print(io, FS)
    Utilities.dump(io, person.dependencies, FS, ES)
end


end
