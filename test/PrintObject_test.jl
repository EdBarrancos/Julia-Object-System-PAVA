using Suppressor
using Test

@defclass(ComplexNumber, [], [real, imag])

@testset "Print object test" begin
    @testset "Print Instance" begin
        obj1 = BaseStructure(
            Object,
            Dict()
        )

        result = @capture_out show(obj1)
        @test result == "<Object " * repr(UInt64(pointer_from_objref(obj1))) * ">"

        c2 = new(ComplexNumber, real=3, imag=4)
        result = @capture_out show(c2)
        @test result == "<ComplexNumber " * repr(UInt64(pointer_from_objref(c2))) * ">"
    end

    @testset "Print Classes" begin
        result = @capture_out show(Object)
        @test result == "<Class Object>"

        result = @capture_out show(Class)
        @test result == "<Class Class>"
    end

    @testset "Print Generic Functions and Methods" begin
        @defmethod gen(a::Object) = begin end

        result = @capture_out show(gen)
        @test result == "<GenericFunction gen with 1 methods>"

        result = @capture_out show(gen.methods[1])
        @test result == "<MultiMethod gen(Object)>"
    end
end