using Raylib
using Raylib: rayvector


const screenWidth = 1600
const screenHeight = 900

function main()
    framesCounter = 0
    pause = false

    Raylib.InitWindow(screenWidth, screenHeight, "this is a test")

    Raylib.SetTargetFPS(30)

    camera = Raylib.RayCamera2D(
        rayvector(screenWidth/2, screenHeight/2),
        rayvector(500, 500),
        0,
        1
    )

    while !Raylib.WindowShouldClose()

        Raylib.BeginDrawing()

        Raylib.ClearBackground(Raylib.LIGHTGRAY)
        
        Raylib.BeginMode2D(camera)
        
        rect = Raylib.RayRectangle(500, 500, 100, 100)
        
        Raylib.DrawRectangleRec(rect, Raylib.RED)
        
        Raylib.EndMode2D()

        Raylib.DrawText("Bla Bla", 20, 20, 10, Raylib.BLACK)

        Raylib.EndDrawing()
    end

    Raylib.CloseWindow()
end

main()
