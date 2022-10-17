using MiniObserve

@observe Data model begin
    @for house in model.houses begin
        @stat("hh_size", MeanVarAcc{Float64}, MaxMinAcc{Float64}) <| Float64(length(house.occupants))
    end

    @for person in model.pop begin
        @stat("married", CountAcc) <|     (alive(person) && !isSingle(person))
        @stat("age", MeanVarAcc{Float64}) <| Float64(age(person))
        @stat("alive", CountAcc) <| alive(person)
        @stat("eligible", CountAcc) <| (alive(person) && isFemale(person) && age(person) > 17)
        @stat("eligible2", CountAcc) <| (alive(person) && isSingle(person) && isFemale(person) && age(person) > 17)
    end
end
