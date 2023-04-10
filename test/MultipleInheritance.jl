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
            :name=>:Screen,
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
            :name=>:Printer,
            :direct_superclasses=>[Device], 
            :direct_slots=>[],
            :class_precedence_list=>[Device, Object, Top],
            :slots=>[]
        )
    )
    pushfirst!(Printer.class_precedence_list, Printer)

    @defgeneric draw(shape, device)

    @defmethod draw(shape::Line, device::Screen) = print("Drawing a line on a screen")
    @defmethod draw(shape::Circle, device::Screen) = print("Drawing a circle on a screen")
    @defmethod draw(shape::Line, device::Printer) = print("Drawing a line on a printer")
    @defmethod draw(shape::Circle, device::Printer) = print("Drawing a circle on a printer")
    
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
    
    @defmethod draw(shape::ColorMixin, device::Device) = print("Drawing a ColorMixin on a Device")

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

        result = @capture_out show(class_direct_superclasses(ColoredCircle))
        @test result == "[<Class ColorMixin>, <Class Circle>]"
        @test class_direct_superclasses(ColoredCircle) == [ColorMixin, Circle]

        result = @capture_out show(class_cpl(ColoredCircle))
        @test result == "[<Class ColoredCircle>, <Class ColorMixin>, <Class Circle>, <Class Object>, <Class Shape>, <Class Top>]"
        @test class_cpl(ColoredCircle) == [ColoredCircle, ColorMixin, Circle, Object, Shape, Top]

        result = @capture_out show(generic_methods(draw))
        @test result == "[<MultiMethod draw(ColorMixin, Device)>, <MultiMethod draw(Circle, Printer)>, <MultiMethod draw(Line, Printer)>, <MultiMethod draw(Circle, Screen)>, <MultiMethod draw(Line, Screen)>]"
        @test generic_methods(draw) == draw.methods

        result = @capture_out show(method_specializers(generic_methods(draw)[begin]))
        @test result == "[<Class ColorMixin>, <Class Device>]"
        @test method_specializers(generic_methods(draw)[begin]) == generic_methods(draw)[begin].specializers
    end

    @testset "Class Hierarchy" begin
        result = ColoredCircle.direct_superclasses
        @test result[1].direct_superclasses == [Object]
        output = @capture_out show(result[1].direct_superclasses)
        @test output == "[<Class Object>]"

        result = result[1].direct_superclasses
        @test result[1].direct_superclasses == [Top]
        output = @capture_out show(result[1].direct_superclasses)
        @test output == "[<Class Top>]"

        result = result[1].direct_superclasses
        @test result[1].direct_superclasses == []
        output = @capture_out show(result[1].direct_superclasses)
        @test output == "[]"
    end
end