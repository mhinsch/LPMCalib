using Raylib
using Raylib: rayvector

# make this less annoying
const RL = Raylib

include("lpm.jl")
include("analysis.jl")

include("src/RayGUI/render.jl")

include("src/RayGUI/SimpleGraph.jl")
using .SimpleGraph

const screenWidth = 1600
const screenHeight = 900

function main()
    # need to do that first, otherwise it blocks the GUI
    simPars, pars = loadParameters(ARGS)
    model = setupModel(pars)


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
            step!(model, time, simPars, pars)
            time += simPars.dt
            data = observe(Data, model)
            # add values to graph objects
            add_value!(graph_pop, data.alive.n)
            add_value!(graph_hhs, data.eligible2.n)
            add_value!(graph_marr, data.married.n)
            add_value!(graph_age, data.age.mean)
            println(data.hh_size.max, " ", data.alive.n, " ", data.eligible.n, " ", data.eligible2.n)
        end

        RL.BeginDrawing()

        RL.ClearBackground(RL.LIGHTGRAY)
        
        RL.BeginMode2D(camera)
        
        drawModel(model, (0, 0), (50, 50), (2, 2))
        # draw graphs
        draw_graph(1000, 0, 600, 900, [graph_pop, graph_marr, graph_hhs, graph_age], 
                   single_scale=false, 
                   labels=["#alive", "#eligible2", "#married", "mean age"])
        
        RL.EndMode2D()

        RL.DrawText("$(Float64(time))", 20, 20, 20, RL.BLACK)

        RL.EndDrawing()
    end

    RL.CloseWindow()
end

main()
