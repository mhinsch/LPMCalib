using MiniObserve

# mean and variance
const MVA = MeanVarAcc{Float64}
# maximum, minimum
const MMA = MaxMinAcc{Float64}

const I = Iterators


not_in_education(person) = 
	    person.status != WorkStatus.student && 
	    person.status != WorkStatus.child && 
	    person.status != WorkStatus.teenager 
	    
potential_worker(person) = !statusChild(person) && !statusTeenager(person) && !statusRetired(person)
	    
# 9 bins since we throw away the top decile in the empirical data
function income_deciles(pop, n_bins = 9)
    incomes = [ p.income for p in pop if not_in_education(p) ]
	    
    sort!(incomes)

    dec_size = length(incomes) ÷ n_bins
    inc_decs = zeros(n_bins)
    
    for i in 1:(n_bins*dec_size)
        inc = incomes[i]
        inc_decs[(i-1) ÷ dec_size + 1] += inc
    end

    inc_decs ./ dec_size
end


function empl_status_hh(hh)
	employed = false
	unemployed = false
	inactive = false
	
	for p in hh.occupants
		if statusWorker(p)
			employed = true
		elseif statusUnemployed(p)
			unemployed = true
		else
			inactive = true
		end
	end
	
	# convert to bitmask
	employed-1 + (unemployed-1) * 2 + (inactive-1) * 4
end

@observe Data model ctime begin

	@record "time" ctime
	
	@for house in I.filter(h->!isEmpty(h), model.houses) begin
	    # all occupied houses
        @stat("hh_size", MVA, HistAcc(0.0, 1.0)) <| Float64(length(house.occupants))
        
	    # households with children
        i_c = findfirst(p->p.age<18, house.occupants)
        if i_c != nothing
            child = house.occupants[i_c]
            is_lp = !isOrphan(child) && isSingle(child.guardians[1])
        else
            is_lp = false
        end

        # all hh with children
        @stat("n_all_chhh", CountAcc) <| (i_c != nothing) 
        # hh with children with lone parents
        @stat("n_lp_chhh", CountAcc) <| is_lp
        # number of siblings in lp households
        @if is_lp @stat("n_ch_lp_hh", HistAcc(0, 1)) <| count(p->p.age<18, house.occupants)
        # age histo of one-person hhs
		@if (length(house.occupants) == 1) @stat("hhs1_age", HistAcc(0.0, 1.0)) <| 
			Float64(house.occupants[1].age)
			
		# employment status
		@stat("hh_empl_status", HistAcc(0, 1)) <| empl_status_hh(house)
    end

    # mothers' ages for all children born in the last year
    @for person in I.filter(p->p.age < 1, model.pop) begin
        m = person.mother

        # age histogram
        a = Float64(m.age) - Float64(person.age)
        @stat("age_mother", HistAcc(0.0, 1.0)) <| a

        # age x class
        c = m.classRank
        @if a < 25 @stat("class_young_mothers", HistAcc(0, 1)) <| c
        @if 25 <= a < 34 @stat("class_mid_mothers", HistAcc(0, 1)) <| c
        @if 34 <= a  @stat("class_old_mothers", HistAcc(0, 1)) <| c

        # no. of previous children
        @stat("n_prev_children", HistAcc(0, 1)) <| (nChildren(m)-1)
    end

    # age histograms for the full population
    @for person in model.pop begin
        @stat("hist_age", HistAcc(0.0, 1.0)) <| Float64(person.age)
    end
    
    #
    @for person in I.filter(potential_worker, model.pop) begin
        age_g = if person.age <= 24
		        0
			elseif person.age <= 34
				1
			elseif person.age <= 49
				2
			else
				3
			end
			
		status = if statusWorker(person)
				0
			elseif statusUnemployed(person)
				1
			else
				2
			end
			
		family_status =
			# implies living at home
			if hasDependents(person)
				if isSingle(person)
					3
				else
					isFemale(person) ? 1 : 2
				end
			else
				isFemale(person) ? 4 : 5
			end
			
		# status by age group
		@if age_g == 0 @stat("empl_by_age_0", HistAcc(0, 1, 2)) <| status
		@if age_g == 1 @stat("empl_by_age_1", HistAcc(0, 1, 2)) <| status
		@if age_g == 2 @stat("empl_by_age_2", HistAcc(0, 1, 2)) <| status
		
		# % employed by family status
		@if status == 0 @stat("empl_by_family", HistAcc(1, 1)) <| family_status
		@stat("all_by_family", HistAcc(1, 1)) <| family_status
					
		# unemployment by class
		@if status == 0 @stat("empl_by_class", HistAcc(0, 1)) <| person.classRank
		@if status == 1 @stat("unempl_by_class", HistAcc(0, 1)) <| person.classRank
    end
    
    # class histograms for the full population (sans children and students)
    @for person in I.filter(not_in_education, model.pop) begin
        class = person.classRank
        
        @stat("hist_class", HistAcc(0.0, 1.0)) <| Float64(person.classRank)

        @if class==0 @stat("hist_age_c0", HistAcc(0.0, 1.0)) <| Float64(person.age)
        @if class==1 @stat("hist_age_c1", HistAcc(0.0, 1.0)) <| Float64(person.age)
        @if class==2 @stat("hist_age_c2", HistAcc(0.0, 1.0)) <| Float64(person.age)
        @if class==3 @stat("hist_age_c3", HistAcc(0.0, 1.0)) <| Float64(person.age)
        @if class==4 @stat("hist_age_c4", HistAcc(0.0, 1.0)) <| Float64(person.age)
    end

    @record "income_deciles" Vector{Float64} income_deciles(model.pop)

    @for person in I.filter(p->isFemale(p) && !isSingle(p) && p.pTime <= 1, model.pop) begin
        agediff = Float64(person.partner.age - person.age)
        # -20.5, so that the lowest bin is [-Inf, -19.5]
        @stat("couple_age_diff", HistAcc(-20.5, 1.0, count_below_min=true)) <| agediff
    end
end
