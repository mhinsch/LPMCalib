using MiniObserve

# mean and variance
const MVA = MeanVarAcc{Float64}
# maximum, minimum
const MMA = MaxMinAcc{Float64}

const I = Iterators


not_in_education(person) = 
	    status(person) != WorkStatus.student && 
	    status(person) != WorkStatus.child && 
	    status(person) != WorkStatus.teenager 

# 9 bins since we throw away the top decile in the empirical data
function income_deciles(pop, n_bins = 9)
    incomes = [ income(p) for p in pop if not_in_education(p) ]
	    
    sort!(incomes)

    dec_size = length(incomes) ÷ n_bins
    inc_decs = zeros(n_bins)
    
    for i in 1:(n_bins*dec_size)
        inc = incomes[i]
        inc_decs[(i-1) ÷ dec_size + 1] += inc
    end

    inc_decs ./ dec_size
end


@observe Data model ctime pars begin

	@record "time" ctime
	
	@for house in I.filter(h->!isEmpty(h), model.houses) begin
	    # all occupied houses
        @stat("hh_size", MVA, HistAcc(0.0, 1.0)) <| Float64(length(house.occupants))
        
	    # households with children
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
        # age histo of one-person hhs
		@if (length(house.occupants) == 1) @stat("hhs1_age", HistAcc(0.0, 1.0)) <| 
			Float64(age(house.occupants[1]))

        ncs = netCareSupply(house)
        scn = householdSocialCareNeed(house, model, pars.carepars)
        cbn = careBalance(house)
        unmet_pre = min(0, max(ncs, -scn))
        unmet_post = min(0, max(cbn, -scn))
        
        @stat("care_supply", MVA) <| Float64(ncs)
        @stat("unmet_care", MVA) <| Float64(min(cbn, 0))
        @stat("unmet_scare_pre", MVA) <| Float64(unmet_pre)
        @stat("unmet_scare_post", MVA) <| Float64(unmet_post)
    end

    # mothers' ages for all children born in the last year
    @for person in I.filter(p->age(p) < 1, model.pop) begin
        m = mother(person)

        # age histogram
        a = Float64(age(m)) - Float64(age(person))
        @stat("age_mother", HistAcc(0.0, 1.0)) <| a

        # age x class
        c = classRank(m)
        @if a < 25 @stat("class_young_mothers", HistAcc(0, 1)) <| c
        @if 25 <= a < 34 @stat("class_mid_mothers", HistAcc(0, 1)) <| c
        @if 34 <= a  @stat("class_old_mothers", HistAcc(0, 1)) <| c

        # no. of previous children
        @stat("n_prev_children", HistAcc(0, 1)) <| (nChildren(m)-1)
    end

    # age histograms for the full population
    @for person in model.pop begin
        @stat("hist_age", HistAcc(0.0, 1.0)) <| Float64(age(person))
        @stat("p_care_supply", HistAcc(0.0, 4.0), MVA) <| 
            Float64(socialCareSupply(person, pars.carepars))
        @stat("p_care_demand", HistAcc(0.0, 4.0), MVA) <| 
            Float64(socialCareDemand(person, pars.carepars))
    end
    
    # class histograms for the full population (sans children and students)
    @for person in I.filter(not_in_education, model.pop) begin
        class = classRank(person)
        
        @stat("hist_class", HistAcc(0.0, 1.0)) <| Float64(classRank(person))

        @if class==0 @stat("hist_age_c0", HistAcc(0.0, 1.0)) <| Float64(age(person))
        @if class==1 @stat("hist_age_c1", HistAcc(0.0, 1.0)) <| Float64(age(person))
        @if class==2 @stat("hist_age_c2", HistAcc(0.0, 1.0)) <| Float64(age(person))
        @if class==3 @stat("hist_age_c3", HistAcc(0.0, 1.0)) <| Float64(age(person))
        @if class==4 @stat("hist_age_c4", HistAcc(0.0, 1.0)) <| Float64(age(person))
    end

    @record "income_deciles" Vector{Float64} income_deciles(model.pop)

    @for person in I.filter(p->isFemale(p) && !isSingle(p) && pTime(p) <= 1, model.pop) begin
        agediff = Float64(age(partner(person)) - age(person))
        # -20.5, so that the lowest bin is [-Inf, -19.5]
        @stat("couple_age_diff", HistAcc(-20.5, 1.0, count_below_min=true)) <| agediff
    end
end
