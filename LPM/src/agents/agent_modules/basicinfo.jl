using Utilities

export isFemale, isMale, hasBirthday, yearsold
export Gender, male, female, unknown

"Gender type enumeration"
@enum Gender unknown female male 


# TODO think about whether to make this immutable
@kwdef struct BasicInfo
    alive :: Bool = true
    age::Rational{Int} = 0//1 
    # (birthyear, birthmonth)
    gender::Gender = unknown 
end

isFemale(person) = person.gender == female
isMale(person) = person.gender == male

hasBirthday(person) = person.age % 1 == 0

function yearsold(person) 
    trunc(Int, person.age)
end 

