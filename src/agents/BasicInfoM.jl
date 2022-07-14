module BasicInfoM

using MultiAgents.Util: date2yearsmonths
using Utilities: Gender, unknown, female, male

export BasicInfo
export isFemale, isMale, agestep!, agestepAlive!, age


# TODO think about whether to make this immutable
mutable struct BasicInfo
  age::Rational 
  # (birthyear, birthmonth)
  gender::Gender  
  alive::Bool 
end

"Default constructor"
BasicInfo(;age=0//1, gender=unknown, alive = true) = BasicInfo(age,gender,alive)

isFemale(person::BasicInfo) = person.gender == female
isMale(person::BasicInfo) = person.gender == male


"costum @show method for Agent person"
function Base.show(io::IO,  info::BasicInfo)
  year, month = date2yearsmonths(info.age)
  print(" $(year) years & $(month) months, $(info.gender) ")
  info.alive ? print(" alive ") : print(" dead ")  
end

age(person::BasicInfo) = person.age

alive(person::BasicInfo) = person.alive

setDead!(person::BasicInfo) = person.alive = false

"increment an age for a person to be used in typical stepping functions"
agestep!(person::BasicInfo; dt=1//12) = person.age += dt  

"increment an age for a person to be used in typical stepping functions"
function agestepAlive!(person::BasicInfo, dt=1//12) 
    person.age += person.alive ? dt : 0  
end 

end # BasicInfo
