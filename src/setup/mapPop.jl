using Random

export assignCouplesToHouses!

"Randomly assign a population of couples to non-inhebted set of houses"
function assignCouplesToHouses!(population::Array{Person}, houses::Array{PersonHouse})
    women = [ person for person in population if isFemale(person) ]

    randomhouses = shuffle(houses)

    for woman in women
        house = pop!(randomhouses) 
        
        moveToHouse!(woman, house) 
        if !isSingle(woman)
            moveToHouse!(woman.partner, house)
        end

        for child in woman.dependents
            moveToHouse!(child, house)
        end
    end # for person     

    for person in population
        if person.pos == undefinedHouse
            @assert isMale(person)
            @assert length(randomhouses) >= 1
            moveToHouse!(person, pop!(randomhouses))
        end
    end
end  # function assignCouplesToHouses 
