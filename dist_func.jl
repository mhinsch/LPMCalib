using CSV
using DataFrames
using Statistics

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

    for i in length(emp_both):(len-1)
        push!(emp_both, 0)
    end

    for i in length(sim_both):(len-1)
        push!(sim_both, 0)
    end

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
        for i in length(h):(max_age)
            push!(h, 0)
        end
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
        for i in length(year_sim):6
            push!(year_sim, 0)
        end

        append!(all_emp, year_emp)
        # bin 1 is 0<=x<1
        append!(all_sim, year_sim[2:7])
    end

    @assert length(all_emp) == length(all_sim)

    rel_mean_square_diff_prop(all_emp, all_sim)
end

