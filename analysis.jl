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
    @for person in I.filter(p->age(p) < 1, model.pop) begin
        a = Float64(age(mother(person)))
        c = classRank(mother(person))
        @stat("age_mother", HistAcc(0.0, 1.0)) <| a

        @if a < 25 @stat("class_young_mothers", HistAcc(0, 1)) <| c
        @if 25 <= a < 34 @stat("class_mid_mothers", HistAcc(0, 1)) <| c
        @if 34 <= a  @stat("class_old_mothers", HistAcc(0, 1)) <| c
    end

    # age and class histograms for the full population
    @for person in model.pop begin
        @stat("hist_age", HistAcc(0.0, 1.0)) <| Float64(age(person))
        @stat("hist_class", HistAcc(0.0, 1.0)) <| Float64(classRank(person))

        class = classRank(person)

        @if class==0 @stat("hist_age_c0", HistAcc(0.0, 1.0)) <| Float64(age(person))
        @if class==1 @stat("hist_age_c1", HistAcc(0.0, 1.0)) <| Float64(age(person))
        @if class==2 @stat("hist_age_c2", HistAcc(0.0, 1.0)) <| Float64(age(person))
        @if class==3 @stat("hist_age_c3", HistAcc(0.0, 1.0)) <| Float64(age(person))
        @if class==4 @stat("hist_age_c4", HistAcc(0.0, 1.0)) <| Float64(age(person))
    end

    # age histogram by class
end
