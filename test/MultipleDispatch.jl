using Suppressor
using Test

@testset "Multiple Dispatch test" begin
    @defclass(Shape, [Object], [])
    @defclass(Device, [Object], [])
    @defclass(Line, [Shape], [from, to])
    @defclass(Circle, [Shape], [center, radius])
    @defclass(Screen, [Device], [])
    @defclass(Printer, [Device], [])

    @defgeneric draw(shape, device)

    @defmethod draw(shape::Line, device::Screen) = println("Drawing a line on a screen")
    @defmethod draw(shape::Circle, device::Screen) = println("Drawing a circle on a screen")
    @defmethod draw(shape::Line, device::Printer) = println("Drawing a line on a printer")
    @defmethod draw(shape::Circle, device::Printer) = println("Drawing a circle on a printer")

    screen = new(Screen)
    printer  = new(Printer)
    line  = new(Line)
    circle  = new(Circle)

    result = @capture_out draw(line, screen)
    @test result == "Drawing a line on a screen\n"
    result = @capture_out draw(circle, screen)
    @test result == "Drawing a circle on a screen\n"
    result = @capture_out draw(line, printer)
    @test result == "Drawing a line on a printer\n"
    result = @capture_out draw(circle, printer)
    @test result == "Drawing a circle on a printer\n"
end