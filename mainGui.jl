include("mainHelpers.jl")

include("analysis.jl")

using GLMakie


struct LTTicks{T}
    ticks::T
    offset::Float64
    slope::Float64
end

function Makie.get_ticks(lt::LTTicks, scale, formatter, vmin, vmax)
    lims_transformed = (vmin, vmax) .* lt.slope .+ lt.offset
    tickvals_transformed, ticklabels = Makie.get_ticks(lt.ticks, scale, formatter, lims_transformed...)
    tickvals_untransformed = (tickvals_transformed .- lt.offset) ./ lt.slope
    return tickvals_untransformed, ticklabels
end


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
    
function network!(positions, agent)
    empty!.(positions)
    ac = coords(agent)
    for c in agent.children
        if !c.alive
            continue
        end
        push!(positions[1], ac)
        push!(positions[1], coords(c))
    end
    for c in parents(agent)
        if isUndefined(c) || !c.alive
            continue
        end
        push!(positions[2], ac)
        push!(positions[2], coords(c))
    end
    for c in siblings(agent)
        if isUndefined(c) || !c.alive
            continue
        end
        push!(positions[3], ac)
        push!(positions[3], coords(c))
    end
end

function create_map!(fig, model)
    #ax_left = Axis(fig[1:2, 1])
    towns = [Rect(t_pos(t)..., 26, 26) for t in model.towns]
    colors = [(isempty(t.houses) ? colorant"blue" : colorant"green") for t in model.towns]
    ax_left, _ = poly(fig, towns, color = colors)
    hidespines!(ax_left)
    hidedecorations!(ax_left)
    
    houses = [h_pos(h) for h in model.houses]
    obs_hc = Observable([h_red])
    house_colors!(obs_hc[], model.houses)
    scatter!(houses, color=obs_hc, marker=:rect, markersize=1, markerspace=:data)
    
    positions = Vector{Vector{Tuple{Int, Int}}}()
    push!(positions, [])
    push!(positions, [])
    push!(positions, [])
    obs_positions_c = Observable(positions[1])
    obs_positions_p = Observable(positions[2])
    obs_positions_s = Observable(positions[3])
    lines!(obs_positions_c, color=:yellow)
    lines!(obs_positions_p, color=:black)
    lines!(obs_positions_s, color=:blue)
    
    obs_hc, positions, obs_positions_c, obs_positions_p, obs_positions_s
end


function create_series(fig, labels; args...)
    data = [ [0.0] for l in labels ]
    obsable = Observable(data)
    
    axis, _ = series(fig, obsable; labels=labels, args...)
    axislegend(axis)
    
    obsable, axis
end

function create_barplot(fig, label; args...)
    obsable = Observable([0.0])
    
    axis, _ = barplot(fig, obsable; label=label, args...)
    axislegend(axis)
    
    obsable, axis
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
    
    obs_hc, positions, obs_positions_c, obs_positions_p, obs_positions_s = 
        create_map!(fig[1:2, 1], model)
    
    f_agent = rand(model.pop)
    
    obs_pop, ax_pop = create_series(fig[1, 2], ["population size", "#married", "working ft"];
        axis=(; xticks=LTTicks(WilkinsonTicks(5), 1920.0, 1/12)))
        
    obs_age, ax_age = create_barplot(fig[1, 3], "population pyramid"; direction=:x, 
        axis=(; yticks=LTTicks(WilkinsonTicks(10), 0.0, 3.0)))
    
    obs_careneed, ax_careneed = create_barplot(fig[2,2][1,1], "care need")
    obs_class, ax_class = create_barplot(fig[2,2][1,2], "social class")
    obs_inc_dec, ax_inc_dec = create_barplot(fig[2,2][2,1], "income deciles")
    obs_age_diff, ax_age_diff = create_barplot(fig[2,2][2,2], "couple age diff",
        axis=(; xticks=LTTicks(WilkinsonTicks(5), -10.0, 1.0)))
    
    obs_care, ax_care = create_series(fig[2,3], ["care supply", "unmet care need"],
        axis=(; xticks=LTTicks(WilkinsonTicks(5), 1920.0, 1/12)))
    
    
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
    on(randbutton.clicks) do clicks; f_agent = rand(model.pop); end
    
    obs_agent= Observable("")
    Label(fig[3,1][1,3], obs_agent, tellwidth=false, justification=:left)
    
    time = Rational(pars.poppars.startTime)
    while goon[]

        if !pause[] && time <= pars.poppars.finishTime
            stepModel!(model, time, pars)
            time += simPars.dt
            data = observe(Data, model, time, pars)
            log_results(logfile, data)
            
            # add values to graph objects
            push!(obs_pop[][1], data.alive.n)
            push!(obs_pop[][2], data.married.n)
            push!(obs_pop[][3], data.work_ft.n)
            
            push!(obs_care[][1], data.care_supply.mean)
            push!(obs_care[][2], data.unmet_care.mean)
            
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
        if !f_agent.alive
            f_agent = rand(model.pop)
        end
        network!(positions, f_agent)
        
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
        n_sibs = count(x->!isUndefined(x), siblings(f_agent))
        n_ch = count(x->!isUndefined(x), f_agent.children)
        obs_agent[] = "age: $(floor(Int, f_agent.age))\n" * 
            "status: $m_status\n" *
            "living parents: $m_s $f_s\n" *
            "$n_sibs siblings\n" *
            "$n_ch children\n" *
            "care need: $(f_agent.careNeedLevel)"  
        obs_year[] = "$(floor(Int, Float64(time)))"
    end


    close(logfile)
end

if ! isinteractive()
    main()
end
