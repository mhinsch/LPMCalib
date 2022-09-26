using Raylib
using Raylib: rayvector

# make this less annoying
const RL = Raylib

include("mainHelpers.jl")

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
        rayvector(500, 500),
        0,
        1
    )

    graph = Graph{Float64}(RL.BLUE)

    pause = false
    time = Rational(simPars.startTime)
    while !RL.WindowShouldClose()

        if !pause && time <= simPars.finishTime
            step!(model, time, simPars, pars)
            time += simPars.dt
            add_value!(graph, rand())
        end

        RL.BeginDrawing()

        RL.ClearBackground(RL.LIGHTGRAY)
        
        RL.BeginMode2D(camera)
        
        drawModel(model, (0, 0), (50, 50), (2, 2))
        draw_graph(1000, 0, 600, 900, [graph])
        
        RL.EndMode2D()

        RL.DrawText("$(Float64(time))", 20, 20, 20, RL.BLACK)

        RL.EndDrawing()
    end

    RL.CloseWindow()
end

main()
