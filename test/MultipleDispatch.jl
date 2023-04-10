using Suppressor
using Test

@testset "Multiple Dispatch test" begin
    @defclass(Shape, [Object], [])
    @defclass(Device, [Object], [])
    @defclass(Line, [Shape], [])
    @defclass(Circle, [Shape], [])
    @defclass(Screen, [Device], [])
    @defclass(Printer, [Device], [])

    @defgeneric draw(shape, device)

    @defmethod draw(shape::Line, device::Screen) = print("Drawing a line on a screen")
    @defmethod draw(shape::Circle, device::Screen) = print("Drawing a circle on a screen")
    @defmethod draw(shape::Line, device::Printer) = print("Drawing a line on a printer")
    @defmethod draw(shape::Circle, device::Printer) = print("Drawing a circle on a printer")

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