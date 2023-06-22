include("mainHelpers.jl")

include("analysis.jl")

using GLMakie


function setto!(a1::AbstractVector, a2::AbstractVector)
    resize!(a1, length(a2))
    a1[:] = a2
end

const h_red = colorant"red"
const h_black = colorant"black"



function house_colors!(cols, houses)
    resize!(cols, length(houses))
    for (i, h) in enumerate(houses)
        cols[i] = isempty(h.occupants) ? h_black : h_red
    end
end

t_pos(t) = t.pos[1]*27, (12-t.pos[2])*27
h_pos(h) = t_pos(h.town) .+ h.pos 

coords(agent) = h_pos(agent.pos)
    
function network!(poss, agent)
    empty!.(poss)
    ac = coords(agent)
    for c in children(agent)
        if !alive(c)
            continue
        end
        push!(poss[1], ac)
        push!(poss[1], coords(c))
    end
    for c in parents(agent)
        if isUndefined(c) || !alive(c)
            continue
        end
        push!(poss[2], ac)
        push!(poss[2], coords(c))
    end
    for c in siblings(agent)
        if isUndefined(c) || !alive(c)
            continue
        end
        push!(poss[3], ac)
        push!(poss[3], coords(c))
    end
end
    

function main(parOverrides...)
    args = copy(ARGS)

    for pov in parOverrides
        push!(args, string(pov))
    end

    # need to do that first, otherwise it blocks the GUI
    simPars, pars, args = loadParameters(args)

    model = setupModel(pars)
    logfile = setupLogging(simPars)

    GLMakie.activate!()
    fig = Figure(resolution=(1600,900))
    
    #ax_left = Axis(fig[1:2, 1])
    towns = [Rect(t_pos(t)..., 26, 26) for t in model.towns]
    cols = [(isempty(t.houses) ? colorant"blue" : colorant"green") for t in model.towns]
    ax_left, _ = poly(fig[1:2, 1], towns, color = cols)
    hidespines!(ax_left)
    hidedecorations!(ax_left)
    
    houses = [h_pos(h) for h in model.houses]
    obs_hc = Observable([h_red])
    house_colors!(obs_hc[], model.houses)
    scatter!(houses, color=obs_hc, marker=:rect, markersize=1, markerspace=:data)
    
    poss = Vector{Vector{Tuple{Int, Int}}}()
    push!(poss, [])
    push!(poss, [])
    push!(poss, [])
    obs_poss_c = Observable(poss[1])
    obs_poss_p = Observable(poss[2])
    obs_poss_s = Observable(poss[3])
    lines!(obs_poss_c, color=:yellow)
    lines!(obs_poss_p, color=:black)
    lines!(obs_poss_s, color=:blue)
    follow_agent = rand(model.pop)
    
    dat_pop = [0.0] 
    dat_marr = [0.0] 
    obs_pop = Observable([dat_pop, dat_marr])
    ax_pop, _ = series(fig[1,2], obs_pop, labels=["N", "#married"])
    axislegend(ax_pop)
    
    obs_age = Observable([0.0])
    ax_age, _ = barplot(fig[1,3], obs_age, label="population pyramid", direction=:x)
    axislegend(ax_age)
    
    obs_careneed = Observable([0.0])
    obs_class = Observable([0.0])
    obs_inc_dec = Observable([0.0])
    obs_age_diff = Observable([0.0])
    ax_careneed, _ = barplot(fig[2,2][1,1], obs_careneed, label="care need")
    ax_class, _ = barplot(fig[2,2][1,2], obs_class, label="class")
    ax_inc_dec, _ = barplot(fig[2,2][2,1], obs_inc_dec, label="income dec")
    ax_age_diff, _ = barplot(fig[2,2][2,2], obs_age_diff, label="age diff")
    axislegend(ax_careneed)
    axislegend(ax_class)
    axislegend(ax_inc_dec)
    axislegend(ax_age_diff)
    
    dat_cares = [0.0]
    dat_careb = [0.0]
    obs_care = Observable([dat_cares, dat_careb])
    ax_care, _ = series(fig[2,3], obs_care, labels=["care supply", "unmet care"])
    axislegend(ax_care)
    
    #dat_f_status = Vector{Float64}()
    #dat_m_status = Vector{Float64}()
    
    display(fig)
    
    runbutton = Button(fig[3,3][1,1]; label = "run", tellwidth = false)    
    pause = Observable(false)
    on(runbutton.clicks) do clicks; pause[] = !pause[]; end
    quitbutton = Button(fig[3,3][1,2]; label = "quit", tellwidth = false)    
    goon = Observable(true)
    on(quitbutton.clicks) do clicks; goon[]=false; end
    
    obs_year = Observable("")
    Label(fig[3,1][1,1], obs_year, tellwidth=false, fontsize=25)
    
    randbutton = Button(fig[3,1][1,2]; label = "agent", tellwidth = false)    
    on(randbutton.clicks) do clicks; follow_agent = rand(model.pop); end
    
    obs_agent= Observable("")
    Label(fig[3,1][1,3], obs_agent, tellwidth=false)
    
    time = Rational(pars.poppars.startTime)
    while goon[]

        if !pause[] && time <= pars.poppars.finishTime
            stepModel!(model, time, pars)
            time += simPars.dt
            data = observe(Data, model, time, pars)
            log_results(logfile, data)
            
            # add values to graph objects
            push!(dat_pop, data.alive.n)
            push!(dat_marr, data.married.n)
            
            push!(dat_cares, data.care_supply.mean)
            push!(dat_careb, data.unmet_care.mean)
            
            setto!(obs_careneed[], data.careneed.bins)
            setto!(obs_class[], data.class.bins)
            setto!(obs_inc_dec[], data.income_deciles)
            setto!(obs_age_diff[], data.age_diff.bins)
            
            setto!(obs_age[], data.age.bins)
            
            house_colors!(obs_hc[], model.houses)
            #setto!(dat_f_status, data.f_status.bins)
            #setto!(dat_m_status, data.m_status.bins)
            
            println(data.hh_size.max, " ", data.alive.n, " ", data.single.n, 
                    " ", data.income.mean)
        end
        
        if pause[]
            sleep(0.001)
        end
        if !alive(follow_agent)
            follow_agent = rand(model.pop)
        end
        network!(poss, follow_agent)
        
        notify(obs_hc)
        notify(obs_poss_c)
        notify(obs_poss_p)
        notify(obs_poss_s)
        
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
        
        obs_agent[] = "age: $(floor(Int, age(follow_agent)))\n" * 
            "care need: $(careNeedLevel(follow_agent))"  
        obs_year[] = "$(floor(Int, Float64(time)))"
    end


    close(logfile)
end

if ! isinteractive()
    main()
end
