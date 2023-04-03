using Suppressor
using Test

@testset "Multiple Dispatch test" begin
    Shape = BaseStructure(
        Class,
        Dict(
            :name=>:Shape,
            :direct_superclasses=>[Object], 
            :direct_slots=>[],
            :class_precedence_list=>[Object],
            :slots=>[]
        )
    )
    pushfirst!(Shape.class_precedence_list, Shape)

    Device = BaseStructure(
        Class,
        Dict(
            :name=>:Device,
            :direct_superclasses=>[Object], 
            :direct_slots=>[],
            :class_precedence_list=>[Object],
            :slots=>[]
        )
    )
    pushfirst!(Device.class_precedence_list, Device)

    Line = BaseStructure(
        Class,
        Dict(
            :name=>:Line,
            :direct_superclasses=>[Shape], 
            :direct_slots=>[],
            :class_precedence_list=>[Shape, Object],
            :slots=>[]
        )
    )
    pushfirst!(Line.class_precedence_list, Line)

    Circle = BaseStructure(
        Class,
        Dict(
            :name=>:Line,
            :direct_superclasses=>[Shape], 
            :direct_slots=>[],
            :class_precedence_list=>[Shape, Object],
            :slots=>[]
        )
    )
    pushfirst!(Circle.class_precedence_list, Circle)

    Screen = BaseStructure(
        Class,
        Dict(
            :name=>:Line,
            :direct_superclasses=>[Device], 
            :direct_slots=>[],
            :class_precedence_list=>[Device, Object],
            :slots=>[]
        )
    )
    pushfirst!(Screen.class_precedence_list, Screen)

    Printer = BaseStructure(
        Class,
        Dict(
            :name=>:Line,
            :direct_superclasses=>[Device], 
            :direct_slots=>[],
            :class_precedence_list=>[Device, Object],
            :slots=>[]
        )
    )
    pushfirst!(Printer.class_precedence_list, Printer)

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