using MiniObserve

# mean and variance
const MVA = MeanVarAcc{Float64}
# maximum, minimum
const MMA = MaxMinAcc{Float64}

const I = Iterators


# 9 bins since we throw away the top decile in the empirical data
function income_deciles(pop, n_bins = 9)
    incomes = [ income(p) for p in pop ]
    sort!(incomes)

    dec_size = length(pop) ÷ n_bins
    inc_decs = zeros(n_bins)
    
    for i in 1:(n_bins*dec_size)
        inc = incomes[i]
        inc_decs[(i-1) ÷ dec_size + 1] += inc
    end

    inc_decs ./ dec_size
end


@observe Data model begin
    # all occupied houses
    @for house in I.filter(h->!isEmpty(h), model.houses) begin
        @stat("hh_size", MVA, HistAcc(0.0, 1.0)) <| Float64(length(house.occupants))
    end

    # households with children
    @for house in Iterators.filter(h->!isEmpty(h), model.houses) begin
        i_c = findfirst(p->age(p)<18, house.occupants)
        if i_c != nothing
            child = house.occupants[i_c]
            is_lp = !isOrphan(child) && isSingle(guardians(child)[1])
        else
            is_lp = false
        end

        # all hh with children
        @stat("n_all_chhh", CountAcc) <| (i_c != nothing) 
        # hh with children with lone parents
        @stat("n_lp_chhh", CountAcc) <| is_lp
        # number of siblings in lp households
        @if is_lp @stat("n_ch_lp_hh", HistAcc(0, 1)) <| count(p->age(p)<18, house.occupants)
    end

    # mothers' ages for all children born in the last year
    @for person in I.filter(p->age(p) < 1, model.pop) begin
        m = mother(person)

        # age histogram
        a = Float64(age(m))
        @stat("age_mother", HistAcc(0.0, 1.0)) <| a

        # age x class
        c = classRank(m)
        @if a < 25 @stat("class_young_mothers", HistAcc(0, 1)) <| c
        @if 25 <= a < 34 @stat("class_mid_mothers", HistAcc(0, 1)) <| c
        @if 34 <= a  @stat("class_old_mothers", HistAcc(0, 1)) <| c

        # no. of previous children
        @stat("n_prev_children", HistAcc(0, 1)) <| (nChildren(m)-1)
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

    @record "income_deciles" Vector{Float64} income_deciles(model.pop)

    @for person in Iterators.filter(p->isFemale(p) && !isSingle(p), model.pop) begin
        agediff = Float64(age(partner(person)) - age(person))
        @stat("couple_age_diff", HistAcc(-5.0, 1.0, count_below_min=true)) <| agediff
    end
end
