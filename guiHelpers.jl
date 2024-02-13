
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


function proportions(histo)
    hsum = sum(histo)
    histo ./ hsum
end


function setto!(a1::AbstractVector, a2::AbstractVector)
    resize!(a1, length(a2))
    a1[:] = a2
end

const town_size = 26

t_pos(t) = t.pos[1] * (town_size+1), (12-t.pos[2]) * (town_size+1)
h_pos(h) = t_pos(h.town) .+ h.pos 

coords(agent) = h_pos(agent.pos)

const h_red = colorant"red"
const h_black = colorant"black"


function update_house_colors!(cols, houses)
    empty!(cols)
    for h in houses
        push!(cols, isempty(h.occupants) ? h_black : h_red)
    end
end

# draw map with towns, houses and focal agent
function create_map!(fig, model)
# *** map (towns = green land, otherwise blue water)
    #ax_left = Axis(fig[1:2, 1])
    towns = [Rect(t_pos(t)..., town_size, town_size) for t in model.towns]
    colors = [(isempty(t.houses) ? colorant"blue" : colorant"green") for t in model.towns]
    ax_left, _ = poly(fig, towns, color = colors)
    hidespines!(ax_left)
    hidedecorations!(ax_left)
    
# *** houses, colour marks occupancy
    houses = [h_pos(h) for h in model.houses]
    colors = typeof(h_red)[]
    update_house_colors!(colors, model.houses)
    obs_hc = Observable(colors)
    scatter!(houses, color=obs_hc, marker=:rect, markersize=1, markerspace=:data)
    
# *** connections between focal agent and relatives
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
    
    # return all observables; changing these updates the map
    obs_hc, positions, obs_positions_c, obs_positions_p, obs_positions_s
end

# update network of relatives for agent
function update_network!(positions, agent)
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


task_pos(t) = Float64(taskTimeToDay(t)), Float64((25-taskTimeToHour(t)))


function update_calendar!(assigned, open, work, busy, agent)
    empty!(assigned)
    for t in agent.assignedTasks
        push!(assigned, task_pos(t.time) .+ (.4, .4))
    end
    empty!(open)
    for t in agent.openTasks
        push!(open, task_pos(t.time) .+ (.4, .4))
    end
    empty!(work)
    for t in 1:24*7
        if agent.jobSchedule[t]
            push!(work, task_pos(t) .+ (.1, .1))
        end
        busy[t] = howBusyAt(agent, t) 
    end
end


function create_calendar!(fig, agent)
    cells = [Rect(day, hour, 0.8, 0.8) for day in 1:7, hour in 1:24][:] # to Vector
    colors = [ colorant"grey" for i in 1:7*24 ]
    ax_left, _ = poly(fig, cells, color = colors)
    #hidespines!(ax_left)
    #hidedecorations!(ax_left)
    
# *** houses, colour marks occupancy
    assigned = Tuple{Float64, Float64}[]
    open = Tuple{Float64, Float64}[]
    work = Tuple{Float64, Float64}[]
    busy_coords = [ task_pos(t) .+ (.4,.4) for t in 1:24*7 ]
    busy_values = zeros(24*7)
    update_calendar!(assigned, open, work, busy_values, agent)
    obs_assigned = Observable(assigned)
    obs_open = Observable(open)
    obs_work = Observable(work)
    obs_busy = Observable(busy_values)
    scatter!(obs_assigned, color=colorant"green", marker=:rect, markersize=.6, markerspace=:data)
    scatter!(obs_open, color=colorant"red", marker=:rect, markersize=.6, markerspace=:data)
    scatter!(obs_work, color=colorant"black", marker=:star8, markersize=.3, markerspace=:data)
    #scatter!(busy_coords, color=busy_values, marker=:circle, markersize=.3, markerspace=:data)
    
    # return all observables; changing these updates the map
    obs_assigned, obs_open, obs_work, obs_busy
end
#=    sched = zeros(Int, 24 * 7)
    
    for t in agent.assignedTasks
        sched[t.time] = 1
    end
    
    for t in agent.openTasks
        sched[t.time] = 2
    end
    
    str = ""
    symb = ["_", "+", "!"]
    
    for hour in 1:24
        for day in 1:7
           s = sched[(day-1) * 24 + hour]
           str *= symb[s+1] * "\t"
        end
        str *= "\n"
    end
    
    str =#


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
