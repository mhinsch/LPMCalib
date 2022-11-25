using Utilities: Gender, unknown, female, male, age2yearsmonths

export isFemale, isMale, agestep!, agestepAlive!, hasBirthday, yearsold


# TODO think about whether to make this immutable
mutable struct BasicInfoBlock
    age::Rational{Int} 
    # (birthyear, birthmonth)
    gender::Gender  
    alive::Bool 
end

"Default constructor"
BasicInfoBlock(;age=0//1, gender=unknown, alive = true) = BasicInfoBlock(age,gender,alive)

isFemale(person::BasicInfoBlock) = person.gender == female
isMale(person::BasicInfoBlock) = person.gender == male


"costum @show method for Agent person"
function Base.show(io::IO,  info::BasicInfoBlock)
  year, month = age2yearsmonths(info.age)
  print(" $(year) years & $(month) months, $(info.gender) ")
  info.alive ? print(" alive ") : print(" dead ")  
end

# setDead!(person::BasicInfoBlock) = person.alive = false

"increment an age for a person to be used in typical stepping functions"
agestep!(person::BasicInfoBlock, dt=1//12) = person.age += dt  

"increment an age for a person to be used in typical stepping functions"
function agestepAlive!(person::BasicInfoBlock, dt=1//12) 
    person.age += person.alive ? dt : 0  
end 

hasBirthday(person::BasicInfoBlock) = person.age % 1 == 0

function yearsold(person::BasicInfoBlock) 
    years, = age2yearsmonths(person.age)
    years 
end 
