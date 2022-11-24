using MiniObserve

# mean and variance
const MVA = MeanVarAcc{Float64}
# maximum, minimum
const MMA = MaxMinAcc{Float64}

@observe Data model begin
    @for house in model.houses begin
        # format:
        # @stat(name, accumulators...) <| expression
        @stat("hh_size", MVA, MMA, HistAcc(1.0, 1.0)) <| Float64(length(house.occupants))
    end

    @for person in Iterators.filter(p->alive(p), model.pop) begin
        @stat("age", MVA, HistAcc(0.0, 1.0)) <| Float64(age(person))
        @stat("married", CountAcc) <| (!isSingle(person))
        @stat("single", CountAcc) <| (age(person) > 18 && isSingle(person))
        @stat("alive", CountAcc) <| true
        @stat("class", HistAcc(0.0, 1.0, 4)) <| Float64(classRank(person))
    end

    @for person in Iterators.filter(p->alive(p)&&isFemale(p), model.pop) begin
        @stat("f_status", HistAcc(0, 1, 5)) <| Int(status(person))
    end

    @for person in Iterators.filter(p->alive(p)&&isMale(p), model.pop) begin
        @stat("m_status", HistAcc(0, 1, 5)) <| Int(status(person))
    end
end
