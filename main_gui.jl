using Raylib
using Raylib: rayvector

# make this less annoying
const RL = Raylib

include("mainHelpers.jl")
include("analysis.jl")

include("src/RayGUI/render.jl")

include("src/RayGUI/SimpleGraph.jl")
using .SimpleGraph

const screenWidth = 1600
const screenHeight = 900

function main()
    # need to do that first, otherwise it blocks the GUI
    simPars, pars = getParameters()
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

    graph_pop = Graph{Float64}(RL.BLUE)
    graph_hhs = Graph{Float64}(RL.WHITE)

    pause = false
    time = Rational(simPars.startTime)
    while !RL.WindowShouldClose()

        if !pause && time <= simPars.finishTime
            step!(model, time, simPars, pars)
            time += simPars.dt
            data = observe(Data, model)
            add_value!(graph_pop, data.N)
            add_value!(graph_hhs, data.hh_size.mean)
        end

        RL.BeginDrawing()

        RL.ClearBackground(RL.LIGHTGRAY)
        
        RL.BeginMode2D(camera)
        
        drawModel(model, (0, 0), (50, 50), (2, 2))
        draw_graph(1000, 0, 600, 900, [graph_pop, graph_hhs], false)
        
        RL.EndMode2D()

        RL.DrawText("$(Float64(time))", 20, 20, 20, RL.BLACK)

        RL.EndDrawing()
    end

    RL.CloseWindow()
end

main()
