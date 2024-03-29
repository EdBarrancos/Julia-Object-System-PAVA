using JuliaObjectSystem
using Suppressor
using Test

@defclass(ComplexNumber, [Object], [real, imag])
@defmethod print_object(c::ComplexNumber, io::_IO) = print(io, "$(c.real)$(c.imag < 0 ? "-" : "+")$(abs(c.imag))i")

@testset "Complex Number Creation" begin

    c1 = new(ComplexNumber, real=1, imag=2)

    @testset "Meta Object tests" begin
        @test class_of(c1) === ComplexNumber
        @test class_of(class_of(c1)) === Class
        @test class_of(class_of(class_of(c1))) === Class

        @test ComplexNumber.direct_slots == [:real, :imag]
        @test Class.slots == [:name, :direct_superclasses, :class_precedence_list, :slots, :direct_subclasses]
        @test ComplexNumber.name == :ComplexNumber
        @test ComplexNumber.direct_superclasses == [Object]
    end

    

    @test getproperty(c1, :real) === c1.real
    @test c1.real == getfield(c1, :slots)[:real]
    @test getproperty(c1, :real) == 1
    

    @test getproperty(c1, :imag) === c1.imag
    @test c1.imag === getfield(c1, :slots)[:imag]

    imag_value = c1.imag
    c1.imag += 3
    @test c1.imag === imag_value + 3

    @testset "Printing Complex Numbers" begin
        result = @capture_out show(c1)
        @test result == "1+5i"
    end 

    @testset "Introspection" begin
        @test class_name(ComplexNumber) == :ComplexNumber
        @test class_direct_slots(ComplexNumber) == [:real, :imag]
        @test class_slots(ComplexNumber) == [:real, :imag]
        @test class_direct_superclasses(ComplexNumber) == [Object]
        @test class_cpl(ComplexNumber) == [ComplexNumber, Object, Top]        
    end
    
    @testset "Compute Getter and Setter" begin
        (getter, setter) = compute_getter_and_setter(ComplexNumber, :real)

        @test getter(c1) == 1

        setter(c1, 11)
        @test getter(c1) == 11
    end
end
