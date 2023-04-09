using Suppressor
using Test

@testset "Multiple Dispatch test" begin
    @defclass(Shape, [Object], [])
    @defclass(Device, [Object], [])
    @defclass(Line, [Shape], [])
    @defclass(Circle, [Shape], [])
    @defclass(Screen, [Device], [])
    @defclass(Printer, [Device], [])

    draw = new_generic_function(:draw, [:shape, :device])
    new_method(draw, :draw, 
        [:shape, :device], 
        [Line, Screen], 
        function (call_next_method, line, device)
            print("Drawing a line on a screen")
        end
    )
    new_method(draw, :draw, 
        [:shape, :device], 
        [Circle, Screen], 
        function (call_next_method, line, device)
            print("Drawing a circle on a screen")
        end
    )
    new_method(draw, :draw, 
        [:shape, :device], 
        [Line, Printer], 
        function (call_next_method, line, device)
            print("Drawing a line on a printer")
        end
    )
    new_method(draw, :draw, 
        [:shape, :device], 
        [Circle, Printer], 
        function (call_next_method, line, device)
            print("Drawing a circle on a printer")
        end
    )

    screen = BaseStructure(Screen, Dict())
    printer  = BaseStructure(Printer, Dict())
    line  = BaseStructure(Line, Dict())
    circle  = BaseStructure(Circle, Dict())

    result = @capture_out draw(line, screen)
    @test result == "Drawing a line on a screen"
    result = @capture_out draw(circle, screen)
    @test result == "Drawing a circle on a screen"
    result = @capture_out draw(line, printer)
    @test result == "Drawing a line on a printer"
    result = @capture_out draw(circle, printer)
    @test result == "Drawing a circle on a printer"
end