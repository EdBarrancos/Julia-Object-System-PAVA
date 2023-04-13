using Suppressor
using Test
@defclass(Shape, [Object], [])
    @defclass(Device, [Object], [])
    @defclass(Line, [Shape], [from, to])
    @defclass(Circle, [Shape], [center, radius])
    @defclass(Screen, [Device], [])
    @defclass(Printer, [Device], [])

    @defgeneric draw(shape, device)

    @defmethod draw(shape::Line, device::Screen) = print("Drawing a line on a screen")
    @defmethod draw(shape::Circle, device::Screen) = print("Drawing a circle on a screen")
    @defmethod draw(shape::Line, device::Printer) = print("Drawing a line on a printer")
    @defmethod draw(shape::Circle, device::Printer) = print("Drawing a circle on a printer")
    
    @defclass(ColorMixin, [], [[color, reader=get_color, writer=set_color!]])
    
    @defmethod draw(shape::ColorMixin, device::Device) =
        let previous_color = get_device_color(d)
            set_device_color!(d, get_color(s))
            call_next_method()
            set_device_color!(d, previous_color)
        end

    @defclass(ColoredLine, [ColorMixin, Line], [])
    @defclass(ColoredCircle, [ColorMixin, Circle], [])

    @defclass(ColoredPrinter, [Printer], 
            [[ink=:black, reader=get_device_color, writer=_set_device_color!]])
    
    @defmethod set_device_color!(d::ColoredPrinter, color) = begin
        println("Changing printer ink color to $color")
        _set_device_color!(d, color)
    end
    let shapes = [new(Line), new(ColoredCircle, color=:red), new(ColoredLine, color=:blue)], printer = new(ColoredPrinter, ink=:black)
        for shape in shapes
            draw(shape, printer)
        end
    end
    
    draw.methods[1].procedure

@testset "Multiple Inheritance test" begin
    @defclass(Shape, [Object], [])
    @defclass(Device, [Object], [])
    @defclass(Line, [Shape], [from, to])
    @defclass(Circle, [Shape], [center, radius])
    @defclass(Screen, [Device], [])
    @defclass(Printer, [Device], [])

    @defgeneric draw(shape, device)

    @defmethod draw(shape::Line, device::Screen) = print("Drawing a line on a screen")
    @defmethod draw(shape::Circle, device::Screen) = print("Drawing a circle on a screen")
    @defmethod draw(shape::Line, device::Printer) = print("Drawing a line on a printer")
    @defmethod draw(shape::Circle, device::Printer) = print("Drawing a circle on a printer")
    
    @defclass(ColorMixin, [], [[color, reader=get_color, writer=set_color!]])
    
    @defmethod draw(shape::ColorMixin, device::Device) = begin
        let previous_color = get_device_color(d)
            set_device_color!(d, get_color(s))
            call_next_method()
            set_device_color!(d, previous_color)
        end
    end

    @defclass(ColoredLine, [ColorMixin, Line], [])
    @defclass(ColoredCircle, [ColorMixin, Circle], [])

    @defclass(ColoredPrinter, [Printer], 
            [[ink=:black, reader=get_device_color, writer=_set_device_color!]])
    
    @defmethod set_device_color!(d::ColoredPrinter, color) = begin
        println("Changing printer ink color to $color")
        _set_device_color!(d, color)
    end

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

    @testset "Multiple Inheritance" begin
        line  = new(Line)
        red = new(ColoredCircle, color=:red)
        blue = new(ColoredLine, color=:blue)
        printer = new(ColoredPrinter, ink=:black)

        result = @capture_out draw(line, printer)
        @test result == "Drawing a line on a printer"
        result = @capture_out draw(red, printer)
        @test result == "Changing printer ink color to red\nDrawing a circle on a printer\nChanging printer ink color to black"
        result = @capture_out draw(blue, printer)
        @test result == "Changing printer ink color to blue\nDrawing a line on a printer\nChanging printer ink color to black"
    end
end