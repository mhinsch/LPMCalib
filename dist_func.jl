"""
Distance functions for each data source, plus utilities.
"""



using CSV
using DataFrames
using DataFramesMeta
using Statistics


"Extend vector by pushing len times new element el."
function extend!(vec, len, el = 0)
    for i in length(vec):(len-1)
        push!(vec, el)
    end

    vec
end

# square of the non-overlapping area
function square_non_overlap(dat, sim)
    sum_d = sum(dat)
    prop_d = dat ./ sum_d

    sum_s = sum(sim)
    prop_s = sim ./ sum_s
	
	d = 0.0
	
	for (ed, es) in zip(prop_d, prop_s)
		d += min(ed, es)
	end
	
	(1.0-d)^2
end
	
function sum_square_diff_prop(dat, sim)
    sum_d = sum(dat)
    prop_d = dat ./ sum_d

    sum_s = sum(sim)
    prop_s = sim ./ sum_s

    # sum square difference
    (prop_s .- prop_d).^2 |> sum
end

function mean_square_diff(dat, sim)
    # mean square difference
    msqdiff = (dat .- sim).^2 |> mean
end

function rel_mean_square_diff(dat, sim)
    # mean square difference
    msqdiff = (dat .- sim).^2 |> mean

    # normalise by mean square of 2*original
    # guarantees result to be in [0, 1]
    msqdiff / mean((dat.*2).^2)
end


function dist_pop_pyramid(dat_file, sim_data, obs_time)
    emp_data = CSV.read(dat_file, DataFrame)

    # data in file starts with highest age
    emp_both = reverse(emp_data[!, :males] .+ emp_data[!, :females])

    sim_both = sim_data[obs_time].hist_age.bins

    len = max(length(emp_both), length(sim_both))

    # pad with 0
    extend!(emp_both, len)
    extend!(sim_both, len)

    square_non_overlap(emp_both, sim_both)
end


function dist_soc_status(dat_file, sim_data_all, obs_time)
    emp_data = CSV.read(dat_file, DataFrame)

    min_age = emp_data[!, :Age][1]
    max_age = emp_data[!, :Age][end]

    # make one big vector out of it
    # we are comparing element-wise anyway
    all_emp = Int[]
    append!(all_emp, emp_data[!, :DE])
    append!(all_emp, emp_data[!, :C2])
    append!(all_emp, emp_data[!, :C1])
    append!(all_emp, emp_data[!, :AB])

    sim_data = sim_data_all[obs_time]

    hists_sim = [sim_data.hist_age_c0.bins, 
                 sim_data.hist_age_c1.bins, 
                 sim_data.hist_age_c2.bins, 
                 sim_data.hist_age_c3.bins, 
                 sim_data.hist_age_c4.bins] 

    # make sure all are long enough
    for h in hists_sim
        # extend if necessary
        extend!(h, max_age+1)
        # cut to required size (age 0 is index 1)
        resize!(h, max_age+1)
    end

    # add up last two classes
    hists_sim[4] = hists_sim[4] .+ hists_sim[5]
    pop!(hists_sim)

    all_sim = Int[]
    for h in hists_sim
        append!(all_sim, h[(min_age+1):(max_age+1)])
    end

    @assert length(all_sim) == length(all_emp)

    square_non_overlap(all_emp, all_sim)
end


function dist_hh_size(dat_file, sim_data_all, obs_time)
    emp_data = CSV.read(dat_file, DataFrame)

    all_emp = Int[]
    all_sim = Int[]

    for t in obs_time
        year_emp = emp_data[!, "$(Int(t))"][1:6]
        year_sim = sim_data_all[t].hh_size.bins
        extend!(year_sim, 7)

        append!(all_emp, year_emp)
        # bin 1 is 0<=x<1
        append!(all_sim, year_sim[2:7])
    end

    @assert length(all_emp) == length(all_sim)

    square_non_overlap(all_emp, all_sim)
end


function dist_maternity_age(dat_file, sim_data_all, obs_time, age_min=16, age_max=49)
    emp_data = CSV.read(dat_file, DataFrame)

    @subset!(emp_data, :age .>= age_min, :age .<= age_max)
    emp_births = emp_data[!, :births]
    sim_births = sim_data_all[obs_time].age_mother.bins
    
    # idx is upper age limit of bin in sim data
    extend!(sim_births, age_max+1)

    sim_births = sim_births[(age_min+1):(age_max+1)]

    @assert length(sim_births) == length(emp_births)

    square_non_overlap(emp_births, sim_births)
end


function dist_maternity_age_SES(dat_file, sim_data_all, obs_time, age_min=16, age_max=50)
    emp_data_raw = CSV.read(dat_file, DataFrame)

    sim_data_raw = [sim_data_all[obs_time].class_young_mothers.bins,
                sim_data_all[obs_time].class_mid_mothers.bins,
                sim_data_all[obs_time].class_old_mothers.bins]

    for data in sim_data_raw
        # we have 5 classes in the sim
        extend!(data, 5)
        data[4] += data[5]
        pop!(data)
    end

    sim_data = vcat(sim_data_raw...)
    emp_data = vcat(emp_data_raw[!, 1], emp_data_raw[!, 2], emp_data_raw[!, 3])

    @assert length(sim_data) == length(emp_data)

    square_non_overlap(emp_data, sim_data)
end

function dist_couples_age_diff_uk(dat_file, sim_data_all, obs_time)
    emp_data_raw = CSV.read(dat_file, DataFrame)

    sim_data_raw = sim_data_all[obs_time].couple_age_diff.bins

    sim_data = zeros(nrow(emp_data_raw))

    limits = emp_data_raw[!, :AgeDifference]

    for (i, n) in enumerate(sim_data_raw)
        # bin 1 is actually age diff <= -5
        ad = i-6
        # find the bin this age diff belongs to in the emp data
        idx = searchsortedfirst(limits, ad)
        sim_data[idx] += n
    end

    emp_data = emp_data_raw[!, :Share]
    square_non_overlap(emp_data, sim_data)
end

function dist_couples_age_diff_fr(dat_file, sim_data_all, obs_time)
    emp_data_raw = CSV.read(dat_file, DataFrame)

    sim_data_raw = sim_data_all[obs_time].couple_age_diff.bins

    sim_data = zeros(nrow(emp_data_raw))

    limits = emp_data_raw[!, :diff]

    for (i, n) in enumerate(sim_data_raw)
        # bin 1 is actually age diff < -19
        ad = i-21
        # find the bin this age diff belongs to in the emp data
        idx = min(searchsortedfirst(limits, ad), length(sim_data))
        sim_data[idx] += n
    end

    emp_data = emp_data_raw[!, :prop]
    square_non_overlap(emp_data, sim_data)
end


function dist_num_prev_children(dat_file, sim_data_all, obs_time)
    emp_data_raw = CSV.read(dat_file, DataFrame)

    sim_data = sim_data_all[obs_time].n_prev_children.bins

    n_emp = nrow(emp_data_raw)

    # make sure we have at least as many bins
    extend!(sim_data, n_emp)

    # if we have more, add them to the last one
    for i in (n_emp+1):length(sim_data)
        sim_data[n_emp] += sim_data[i]
    end

    # in case the sim data was actually bigger
    resize!(sim_data, n_emp)

    square_non_overlap(emp_data_raw[!, :Births], sim_data)
end


function dist_income_deciles(dat_file, sim_data_all, obs_time)
    emp_data_raw = CSV.read(dat_file, DataFrame)[1:9, :income]

    sim_data_raw = sim_data_all[obs_time].income_deciles
    
    #println("income: ", sim_data_raw, "; ", emp_data_raw)

    square_non_overlap(emp_data_raw, sim_data_raw)
end


function dist_prop_lphh(sim_data_all, obs_time)
    data = sim_data_all[obs_time]
    lphh_prop = data.n_lp_chhh.n / data.n_all_chhh.n
    square_non_overlap([lphh_prop, 1-lphh_prop], [0.23, 0.77])
end


function dist_empl_status_by_age(dat_file, sim_data_all, obs_time)
	emp_data_raw = CSV.read(dat_file, DataFrame).percentage
	
	sim_data_raw = [ 
		sim_data_all[obs_time].empl_by_age_0.bins, 
		sim_data_all[obs_time].empl_by_age_1.bins, 
		sim_data_all[obs_time].empl_by_age_2.bins  
		]
		
		
	# each age group is its own small histogram, so we use 
	# sum square diff of the normalised data per age group 
	dists = [ 
	  square_non_overlap(emp_data_raw[1:3], sim_data_raw[1]),
	  square_non_overlap(emp_data_raw[4:6], sim_data_raw[2]),
	  square_non_overlap(emp_data_raw[7:9], sim_data_raw[3])]
	  
	
	#println("empl_age: ", dists)
	mean(dists)
end


function dist_empl_by_family_status(dat_file, sim_data_all, obs_time)
	emp_data_raw = CSV.read(dat_file, DataFrame).perc_employed ./ 100.0
	
	sim_data_empl_raw = sim_data_all[obs_time].empl_by_family.bins
	sim_data_all_raw = sim_data_all[obs_time].all_by_family.bins
	
	# if bin exists then count > 0, so this is safe
	sim_data = sim_data_empl_raw ./ sim_data_all_raw
	# just in case
	extend!(sim_data, length(emp_data_raw))
	
	#println("family: ", sim_data, "; ", emp_data_raw)
	# all data in proportions, so simple mean square diff should be fine
	mean_square_diff(emp_data_raw, sim_data)
end


function dist_households_by_empl(dat_file, sim_data_all, obs_time)
	emp_data_raw = CSV.read(dat_file, DataFrame).percentage 
	
	sim_data_raw = sim_data_all[obs_time].hh_empl_status.bins
	# just in case
	extend!(sim_data_raw, length(emp_data_raw))
	
	#println(emp_data_raw, "; ", sim_data_raw)
	square_non_overlap(emp_data_raw, sim_data_raw)
end


function dist_unemployment_by_class(dat_file, sim_data_all, obs_time)
	emp_data_raw = CSV.read(dat_file, DataFrame).unemployment_rate ./ 100
	
	sim_data_raw_empl = sim_data_all[obs_time].empl_by_class.bins
	sim_data_raw_unempl = sim_data_all[obs_time].unempl_by_class.bins
	
	# add 0s if necessary, *raw_empl is always at least as long as *raw_unempl
	extend!(sim_data_raw_unempl, length(sim_data_raw_empl))
	
	# last classes in emp data are lumped
	while length(sim_data_raw_empl) > length(emp_data_raw)
		sim_data_raw_empl[end-1] += sim_data_raw_empl[end]
		sim_data_raw_unempl[end-1] += sim_data_raw_unempl[end]
		pop!(sim_data_raw_empl)
		pop!(sim_data_raw_unempl)
	end
	
	sim_data = sim_data_raw_unempl ./ sim_data_raw_empl 
	extend!(sim_data, length(emp_data_raw))
	
	#println("empl class:", emp_data_raw, "; ", sim_data)
	mean_square_diff(emp_data_raw, sim_data)
end
