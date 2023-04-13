using JuliaObjectSystem
using Suppressor
using Test

@testset "Multiple Inheritance test" begin
    @defclass(Shape, [], [])
    @defclass(Device, [], [])
    @defclass(Line, [Shape], [from, to])
    @defclass(Circle, [Shape], [center, radius])
    @defclass(Screen, [Device], [])
    @defclass(Printer, [Device], [])

    @defgeneric draw(shape, device)

    @defmethod draw(shape::Line, device::Screen) = print("Drawing a line on a screen")
    @defmethod draw(shape::Circle, device::Screen) = print("Drawing a circle on a screen")
    @defmethod draw(shape::Line, device::Printer) = print("Drawing a line on a printer")
    @defmethod draw(shape::Circle, device::Printer) = print("Drawing a circle on a printer")
    
    #TODO Missing reader and writer 

    @defclass(ColorMixin,[],[color])

    @defmethod draw(shape::ColorMixin, device::Device) = print("Drawing a ColorMixin on a Device")


    @defclass(ColoredLine, [ColorMixin, Line], [])
    @defclass(ColoredCircle, [ColorMixin, Circle], [])

    compute_cpl(ColoredCircle)

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
        println(class_cpl(ColoredCircle))

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