using Suppressor
using Test

@testset "Multiple Inheritance test" begin
    Shape = BaseStructure(
        Class,
        Dict(
            :name=>:Shape,
            :direct_superclasses=>[Object], 
            :direct_slots=>[],
            :class_precedence_list=>[Object, Top],
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
            :class_precedence_list=>[Object, Top],
            :slots=>[]
        )
    )
    pushfirst!(Device.class_precedence_list, Device)

    Line = BaseStructure(
        Class,
        Dict(
            :name=>:Line,
            :direct_superclasses=>[Shape], 
            :direct_slots=>[:from, :to],
            :class_precedence_list=>[Shape, Object, Top],
            :slots=>[:from, :to]
        )
    )
    pushfirst!(Line.class_precedence_list, Line)

    Circle = BaseStructure(
        Class,
        Dict(
            :name=>:Circle,
            :direct_superclasses=>[Shape], 
            :direct_slots=>[:center, :radius],
            :class_precedence_list=>[Shape, Object, Top],
            :slots=>[:center, :radius]
        )
    )
    pushfirst!(Circle.class_precedence_list, Circle)

    Screen = BaseStructure(
        Class,
        Dict(
            :name=>:Line,
            :direct_superclasses=>[Device], 
            :direct_slots=>[],
            :class_precedence_list=>[Device, Object, Top],
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
            :class_precedence_list=>[Device, Object, Top],
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
    
    #TODO Missing reader and writer 
    ColorMixin = BaseStructure(
        Class,
        Dict(
            :name=>:ColorMixin,
            :direct_superclasses=>[Object], 
            :direct_slots=>[:color],
            :class_precedence_list=>[Object, Top],
            :slots=>[:color]
        )
    )
    pushfirst!(ColorMixin.class_precedence_list, ColorMixin)
    
    #TODO draw function page 7

    ColoredLine = BaseStructure(
        Class,
        Dict(
            :name=>:ColoredLine,
            :direct_superclasses=>[ColorMixin, Line], 
            :direct_slots=>[],
            # TODO class_cpl to check
            :class_precedence_list=>[ColorMixin, Line, Object, Shape, Top],
            :slots=>[:color, :from, :to]
        )
    )
    pushfirst!(ColoredLine.class_precedence_list, ColoredLine)
    
    ColoredCircle = BaseStructure(
        Class,
        Dict(
            :name=>:ColoredCircle,
            :direct_superclasses=>[ColorMixin, Circle], 
            :direct_slots=>[],
            :class_precedence_list=>[ColorMixin, Circle, Object, Shape, Top],
            :slots=>[:color, :center, :radius]
        )
    )
    pushfirst!(ColoredCircle.class_precedence_list, ColoredCircle)

    @testset "Introspection" begin
        @test class_name(Circle) == :Circle
        @test class_direct_slots(Circle) == [:center, :radius]
        @test class_direct_slots(ColoredCircle) == []
        @test class_slots(ColoredCircle) == [:color, :center, :radius]
        @test class_direct_superclasses(ColoredCircle) == [ColorMixin, Circle]
        @test class_cpl(ColoredCircle) == [ColoredCircle, ColorMixin, Circle, Object, Shape, Top]
    end
end