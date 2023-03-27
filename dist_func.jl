using CSV
using DataFrames
using DataFramesMeta
using Statistics

function extend!(vec, len, el = 0)
    for i in length(vec):(len-1)
        push!(vec, el)
    end

    vec
end


function rel_mean_square_diff_prop(dat, sim)
    sum_d = sum(dat)
    prop_d = dat ./ sum_d

    sum_s = sum(sim)
    prop_s = sim ./ sum_s

    # mean square difference
    msqdiff = (prop_s .- prop_d).^2 |> mean

    # normalise by mean square of 2*original
    # guarantees result to be in [0, 1]
    msqdiff / mean((prop_d.*2).^2)
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

    rel_mean_square_diff_prop(emp_both, sim_both)
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

    rel_mean_square_diff_prop(all_emp, all_sim)
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

    rel_mean_square_diff_prop(all_emp, all_sim)
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

    rel_mean_square_diff_prop(emp_births, sim_births)
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

    rel_mean_square_diff_prop(emp_data, sim_data)
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
    rel_mean_square_diff_prop(emp_data, sim_data)
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
        idx = searchsortedfirst(limits, ad)
        sim_data[idx] += n
    end

    emp_data = emp_data_raw[!, :prop]
    rel_mean_square_diff_prop(emp_data, sim_data)
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

    rel_mean_square_diff_prop(emp_data_raw[!, :Births], sim_data)
end


function dist_income_deciles(dat_file, sim_data_all, obs_time)
    emp_data_raw = CSV.read(dat_file, DataFrame)[1:9, :income]

    sim_data_raw = sim_data_all[obs_time].income_deciles

    rel_mean_square_diff_prop(emp_data_raw, sim_data_raw)
end


function dist_prop_lphh(sim_data_all, obs_time)
    data = sim_data_all[obs_time]
    lphh_prop = data.n_lp_chhh.n / data.n_all_chhh.n
    rel_mean_square_diff_prop([lphh_prop], [0.23])
end
