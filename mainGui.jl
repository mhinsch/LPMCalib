using Raylib
using Raylib: rayvector

# make this less annoying
const RL = Raylib

include("lpm.jl")

include("src/RayGUI/render.jl")

include("src/RayGUI/SimpleGraph.jl")
using .SimpleGraph

function main(parOverrides...)
    args = copy(ARGS)

    for pov in parOverrides
        push!(args, string(pov))
    end

    # need to do that first, otherwise it blocks the GUI
    simPars, pars, args = loadParameters(args, 
        ["--gui-scale"], 
        Dict(:help => "set gui scale", :default => 1.0, :arg_type => Float64))
    model = setupModel(pars)
    logfile = setupLogging(simPars)

    scale = args[:gui_scale]
    screenWidth = floor(Int, 1600 * scale)
    screenHeight = floor(Int, 900 * scale)

    RL.InitWindow(screenWidth, screenHeight, "this is a test")
    RL.SetTargetFPS(30)
    camera = RL.RayCamera2D(
        rayvector(screenWidth/2, screenHeight/2),
        rayvector(screenWidth/2, screenHeight/2),
        #rayvector(500, 500),
        0,
        1
    )

    # create graph objects with colour
    graph_pop = Graph{Float64}(RL.BLUE)
    graph_hhs = Graph{Float64}(RL.WHITE)
    graph_marr = Graph{Float64}(RL.BLACK)
    graph_age = Graph{Float64}(RL.RED)

    pause = false
    time = Rational(simPars.startTime)
    while !RL.WindowShouldClose()

        if !pause && time <= simPars.finishTime
            stepModel!(model, time, simPars, pars)
            time += simPars.dt
            data = observe(Data, model)
            log_results(logfile, data)
            # add values to graph objects
            add_value!(graph_pop, data.alive.n)
            add_value!(graph_hhs, data.hh_size.mean)
            add_value!(graph_marr, data.married.n)
            set_data!(graph_age, data.hist_age.bins, minm=0)
            println(data.hh_size.max, " ", data.alive.n, " ", data.eligible.n, " ", data.eligible2.n)
        end

        if RL.IsKeyPressed(Raylib.KEY_SPACE)
            pause = !pause
            sleep(0.2)
        end

        RL.BeginDrawing()

        RL.ClearBackground(RL.LIGHTGRAY)
        
        RL.BeginMode2D(camera)
        
        drawModel(model, (0, 0), 
                  (floor(Int, 50 * scale), floor(Int, 50 * scale)), 
                  (floor(Int, 2 * scale), floor(Int, 2 * scale)))

        RL.EndMode2D()

        # draw graphs
        draw_graph(floor(Int, screenWidth/3), 0, floor(Int, screenWidth*2/3), screenHeight, 
                   [graph_pop, graph_hhs, graph_marr, graph_age], 
                   single_scale = false, 
                   labels = ["#alive", "hh size", "#married", "age"],
                   fontsize = floor(Int, 15 * scale))
        

        RL.DrawText("$(Float64(time))", 0, 
                    screenHeight - floor(Int, 20 * scale), 
                    floor(Int, 20 * scale), RL.BLACK)

        RL.EndDrawing()
    end

    RL.CloseWindow()

    close(logfile)
end

if ! isinteractive()
    main()
end
