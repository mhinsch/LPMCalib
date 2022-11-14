using MiniObserve

# mean and variance
const MVA = MeanVarAcc{Float64}
# maximum, minimum
const MMA = MaxMinAcc{Float64}

const I = Iterators

@observe Data model begin
    # all occupied houses
    @for house in I.filter(h->!isEmpty(h), model.houses) begin
        @stat("hh_size", MVA, HistAcc(0.0, 1.0)) <| Float64(length(house.occupants))
    end

    # mothers' ages for all children born in the last year
    @for person in I.filter(p->alive(p) && age(p) < 1, model.pop) begin
        @stat("age_mother", HistAcc(0.0, 1.0)) <| Float64(age(mother(person)))
    end

    # age and class histograms for the full population
    @for person in I.filter(p->alive(p), model.pop) begin
        @stat("hist_age", HistAcc(0.0, 1.0)) <| Float64(age(person))
        @stat("hist_class", HistAcc(0.0, 1.0)) <| Float64(classRank(person))
    end

    # age histogram by class
    @for person in I.filter(p->alive(p)&&classRank(p)==0, model.pop) begin
        @stat("hist_age_c0", HistAcc(0.0, 1.0)) <| Float64(age(person))
    end
    @for person in I.filter(p->alive(p)&&classRank(p)==1, model.pop) begin
        @stat("hist_age_c1", HistAcc(0.0, 1.0)) <| Float64(age(person))
    end
    @for person in I.filter(p->alive(p)&&classRank(p)==2, model.pop) begin
        @stat("hist_age_c2", HistAcc(0.0, 1.0)) <| Float64(age(person))
    end
    @for person in I.filter(p->alive(p)&&classRank(p)==3, model.pop) begin
        @stat("hist_age_c3", HistAcc(0.0, 1.0)) <| Float64(age(person))
    end
    @for person in I.filter(p->alive(p)&&classRank(p)==4, model.pop) begin
        @stat("hist_age_c4", HistAcc(0.0, 1.0)) <| Float64(age(person))
    end
end