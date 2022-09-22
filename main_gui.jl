using Raylib
using Raylib: rayvector

# make this less annoying
const RL = Raylib

include("mainHelpers.jl")

include("src/RayGUI/render.jl")


const screenWidth = 1600
const screenHeight = 900

function main()
    framesCounter = 0
    pause = false

    # need to do that first, otherwise it blocks the GUI
    model, simPars, pars = setupModel()


    RL.InitWindow(screenWidth, screenHeight, "this is a test")

    RL.SetTargetFPS(30)

    camera = RL.RayCamera2D(
        rayvector(screenWidth/2, screenHeight/2),
        rayvector(500, 500),
        0,
        1
    )


    while !RL.WindowShouldClose()

        RL.BeginDrawing()

        RL.ClearBackground(RL.LIGHTGRAY)
        
        RL.BeginMode2D(camera)
        
        drawModel(model, (0, 0), (50, 50), (2, 2))
        
        RL.EndMode2D()

        RL.DrawText("Bla Bla", 20, 20, 10, RL.BLACK)

        RL.EndDrawing()
    end

    RL.CloseWindow()
end

main()
