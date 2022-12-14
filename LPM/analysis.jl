using MiniObserve

# mean and variance
const MVA = MeanVarAcc{Float64}
# maximum, minimum
const MMA = MaxMinAcc{Float64}

function income_deciles(pop)
    incomes = [ income(p) for p in pop ]
    sort!(incomes)

    dec_size = length(pop) ÷ 10
    inc_decs = zeros(10)
    
    for i in 1:(10*dec_size)
        inc = incomes[i]
        inc_decs[(i-1) ÷ dec_size + 1] += inc
    end

    inc_decs ./ dec_size
end

@observe Data model begin
    @for house in model.houses begin
        # format:
        # @stat(name, accumulators...) <| expression
        @stat("hh_size", MVA, MMA, HistAcc(1.0, 1.0)) <| Float64(length(house.occupants))
    end

    # households with children
    @for house in Iterators.filter(h->!isEmpty(h), model.houses) begin
        i_c = findfirst(p->age(p)<18, house.occupants)
        if i_c != nothing
            child = house.occupants[i_c]
        end

        is_lp = i_c != nothing && !isOrphan(child) && isSingle(guardians(child)[1])

        # all hh with children
        @stat("n_ch_hh", CountAcc) <| (i_c != nothing) 
        # hh with children with lone parents
        @stat("n_lp_hh", CountAcc) <| is_lp
        # number of children in lp households
        @if is_lp @stat("n_ch_lp_hh", HistAcc(0, 1)) <| count(p->age(p)<18, house.occupants)
    end

    @for person in model.pop begin
        @stat("age", MVA, HistAcc(0.0, 1.0)) <| Float64(age(person))
        @stat("married", CountAcc) <| (!isSingle(person))
        @stat("single", CountAcc) <| (age(person) > 18 && isSingle(person))
        @stat("alive", CountAcc) <| true
        @stat("class", HistAcc(0.0, 1.0, 4.0)) <| Float64(classRank(person))
        @stat("income", MVA) <| income(person)
        @stat("n_orphans", CountAcc) <| isOrphan(person)
    end

    @for person in Iterators.filter(p->alive(p)&&isFemale(p), model.pop) begin
        @stat("f_status", HistAcc(0, 1, 5)) <| Int(status(person))
    end

    @record "income_deciles" Vector{Float64} income_deciles(model.pop)

    @for person in Iterators.filter(p->alive(p)&&isMale(p), model.pop) begin
        @stat("m_status", HistAcc(0, 1, 5)) <| Int(status(person))
    end
end
