module FullModelPerson


using CompositeStructs

using Utilities

using Tasks, Towns, FullModelHouse

export Person
export PersonHouse, PersonTown, PersonTask 
export undefinedPerson, undefinedHouse 
export schoolCareP



using InstitutionsAM
using WorkAM, KinshipAM, MaternityAM, BasicInfoAM, CareAM, ClassAM, DependenciesAM, TasksAM
using BenefitsAM, BasicHouseAM


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
    
    pos::House{Person, Town{House}} = undefinedHouse
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
FullModelHouse.getHomeTown(person::Person) = getHomeTown(person.pos)

# by convention person objects that are institutions have age == -1
InstitutionsAM.isRealPerson(p) = p.age >= 0


const PersonTown = Town{House}
const PersonHouse = House{Person, PersonTown}
const PersonTask = ATask{Person}
const undefinedTown = PersonTown((-1,-1), 0.0)
const undefinedHouse = PersonHouse(undefinedTown, (-1, -1))
const undefinedPerson = Person(nothing)
const undefinedTask = PersonTask(0, undefinedPerson, undefinedPerson, 0, 0, 0)

Utilities.undefined(::T) where {T} = undefinedT(T)
Utilities.undefined(t::DataType) = undefinedT(t)
undefinedT(::Type{PersonHouse}) = undefinedHouse
undefinedT(::Type{House}) = undefinedHouse
undefinedT(::Type{PersonTown}) = undefinedTown
undefinedT(::Type{Person}) = undefinedPerson
undefinedT(::Type{PersonTask}) = undefinedTask

Utilities.isUndefined(t::T) where {T} = t == undefined(t) 


const schoolCareP = Person(nothing)

# currently unused
# TODO move into interaction module
#= function maxParentRank(person)
    f = person.father
    m = person.mother
    if isUndefined(f) && isUndefined(m)
        person.classRank
    elseif isUndefined(f) 
        m.classRank
    elseif isUndefined(m) 
        f.classRank
    else
        max(m.classRank, f.classRank)
    end
end
=#

function TasksAM.howBusyAt(p::Person, hour)
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
