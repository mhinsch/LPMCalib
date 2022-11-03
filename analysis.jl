using MiniObserve

# mean and variance
const MVA = MeanVarAcc{Float64}
# maximum, minimum
const MMA = MaxMinAcc{Float64}

@observe Data model begin
    @for house in model.houses begin
        # format:
        # @stat(name, accumulators...) <| expression
        @stat("hh_size", MVA, MMA) <| Float64(length(house.occupants))
    end

    @for person in model.pop begin
        @stat("married", CountAcc) <| (alive(person) && !isSingle(person))
        @stat("age", MVA) <| Float64(age(person))
        @stat("alive", CountAcc) <| alive(person)
        @stat("eligible", CountAcc) <| (alive(person) && isFemale(person) && age(person) > 17)
        @stat("eligible2", CountAcc) <| (alive(person) && isSingle(person) && isFemale(person) && age(person) > 17)
    end


    @for person in Iterators.filter(p->alive(p), model.pop) begin
        @stat("hist_age", HistAcc(0.0, 1.0)) <| Float64(age(person))
    end
end
