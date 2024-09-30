include("mainHelpers.jl")

include("analysis.jl")

using GLMakie


include("guiHelpers.jl")


function main(parOverrides...)
    args = copy(ARGS)

    for pov in parOverrides
        push!(args, string(pov))
    end

    # need to do that first, otherwise it blocks the GUI
    simPars, pars, args = loadParameters(args)

    model = setupModel(pars)
    logfile = setupLogging(simPars)
    
# *** Window 1

    GLMakie.activate!()
    fig = Figure(size=(1600,900))
    
    obs_hc, positions, obs_positions_c, obs_positions_p, obs_positions_s = 
        create_map!(fig[1:2, 1], model)
    
    f_agent = rand(model.pop)
    
    obs_pop, ax_pop = create_series(fig[1, 2], ["population size", "#married", "working", "unemployed"];
        axis=(; xticks=LTTicks(WilkinsonTicks(5), 1920.0, 1/12)))
        
    obs_age, ax_age = create_barplot(fig[1, 3], "population pyramid"; direction=:x)#, 
        #axis=(; yticks=LTTicks(WilkinsonTicks(10), 0.0, 3.0)))
    
    obs_careneed, ax_careneed = create_barplot(fig[2,2][1,1], "care need")
    obs_class, ax_class = create_barplot(fig[2,2][1,2], "social class")
    obs_inc_dec, ax_inc_dec = create_barplot(fig[2,2][2,1], "income deciles")
    obs_age_diff, ax_age_diff = create_barplot(fig[2,2][2,2], "couple age diff",
        axis=(; xticks=LTTicks(WilkinsonTicks(5), -10.0, 1.0)))
    
    obs_care, ax_care = create_series(fig[2,3], ["care supply", "unmet care need"],
        axis=(; xticks=LTTicks(WilkinsonTicks(5), 1920.0, 1/12)))
        
# *** Window 2
    
    display(GLMakie.Screen(), fig)
    
    fig2 = Figure(size=(600,900))
    display(GLMakie.Screen(), fig2)
    
    obs_assigned, obs_open, obs_work, obs_busy = create_calendar!(fig2[1,1], f_agent)
    
    obs_agent1 = Observable("")
    Label(fig2[2,1][1,1], obs_agent1, tellwidth=false, justification=:left)
    obs_agent2 = Observable("")
    Label(fig2[2,1][1,2], obs_agent2, tellwidth=false, justification=:left)
    
# *** buttons    
    
    runbutton = Button(fig[3,3][1,1]; label = "run", tellwidth = false)    
    pause = Observable(false)
    on(runbutton.clicks) do clicks; pause[] = !pause[]; end
    quitbutton = Button(fig[3,3][1,2]; label = "quit", tellwidth = false)    
    goon = Observable(true)
    on(quitbutton.clicks) do clicks; goon[]=false; end
    
    obs_year = Observable("")
    Label(fig[3,1][1,1], obs_year, tellwidth=false, fontsize=25)
    
    randbutton = Button(fig[3,1][1,2]; label = "agent", tellwidth = false)    
    on(randbutton.clicks) do clicks; f_agent = rand(model.pop); end
    
# *** simulation
    
    time = Rational(pars.poppars.startTime)
    while goon[]

        if !pause[] && time <= pars.poppars.finishTime
            stepModel!(model, time, pars)
            time += simPars.dt
            data = observe(Data, model, time, pars)
            log_results(logfile, data)
            
            # add values to graph objects
            add_series_point!(obs_pop[][1], data.alive.n)
            add_series_point!(obs_pop[][2], data.married.n)
            add_series_point!(obs_pop[][3], data.employed.n)
            add_series_point!(obs_pop[][4], data.unemployed.n)
            
            #push!(obs_care[][1], data.care_supply.mean)
            #push!(obs_care[][2], data.unmet_care.mean)
            add_series_point!(obs_care[][1], data.av_care_time.mean)
            add_series_point!(obs_care[][2], data.open_tasks.mean)
            
            setto!(obs_careneed[], data.careneed.bins)
            setto!(obs_class[], data.class.bins)
            setto!(obs_inc_dec[], data.income_deciles)
            setto!(obs_age_diff[], data.age_diff.bins)
            
            #setto!(obs_age[], data.age.bins)
            setto!(obs_age[], data.n_children.bins |> proportions)
            
            update_house_colors!(obs_hc[], model.houses)
            #setto!(dat_f_status, data.f_status.bins)
            #setto!(dat_m_status, data.m_status.bins)
            
            
            println(data.hh_size.max, " ", data.alive.n, " ", data.single.n, 
                    " ", data.income.mean)
        end
        
        if pause[]
            sleep(0.001)
        end
        if !f_agent.alive
            f_agent = rand(model.pop)
        end
        update_network!(positions, f_agent)
        update_calendar!(obs_assigned[], obs_open[], obs_work[], obs_busy[], f_agent)
        notify(obs_assigned)
        notify(obs_open)
        notify(obs_work)
        notify(obs_busy)
        
        notify(obs_hc)
        notify(obs_positions_c)
        notify(obs_positions_p)
        notify(obs_positions_s)
        
        notify(obs_pop)
        autolimits!(ax_pop)
        
        notify(obs_care)
        autolimits!(ax_care)
        
        notify(obs_careneed)
        autolimits!(ax_careneed)
        notify(obs_class)
        autolimits!(ax_class)
        notify(obs_inc_dec)
        autolimits!(ax_inc_dec)
        notify(obs_age_diff)
        autolimits!(ax_age_diff)
        
        notify(obs_age)
        autolimits!(ax_age)
        
        m_status = isUndefined(f_agent.partner) ? "single" : "married"
        m_s = isUndefined(f_agent.mother) ? "" : "mother"
        f_s = isUndefined(f_agent.father) ? "" : "father"
        n_fsibs, n_hsibs = nSiblings(f_agent)
        n_ch = count(x->!isUndefined(x), f_agent.children)
        obs_agent1[] = "age: $(floor(Int, f_agent.age))\n" * 
            "status: $m_status\n" *
            "living parents: $m_s $f_s\n" *
            "$n_fsibs full siblings\n" *
            "$n_hsibs half siblings\n" *
            "$n_ch children" 
        obs_agent2[] = "$(f_agent.status)\n" * 
            "working hours: $(count(f_agent.jobSchedule))\n" *
            "care need: $(f_agent.careNeedLevel)\n" *
            "#tasks: $(sum(length.(f_agent.todo)))"
            
        obs_year[] = "$(floor(Int, Float64(time)))"
    end


    close(logfile)
end

if ! isinteractive()
    main()
end
