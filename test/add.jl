using JuliaObjectSystem
using Suppressor
using Test

@testset "Create Method and Generic Functions" begin
    @testset "Create Generic Function and Method" begin
        @defgeneric gen(a, b)
        @test class_of(gen) == GenericFunction
        @test class_of(class_of(gen)) == Class
        @test gen.name == :gen
        @test gen.lambda_list == [:a, :b]
        @test length(gen.methods) == 0

        @testset "Method" begin
            @defmethod gen(a::Object, b::Object) = "generic function"
    
            @test class_of(gen) === GenericFunction
            @test class_of(class_of(gen)) === Class
            @test gen.name == :gen
            @test gen.lambda_list == [:a, :b]
            @test length(gen.methods) == 1

            @test class_of(gen.methods[1]) == MultiMethod            
            @test gen.methods[1].generic_function === gen
            @test length(gen.methods[1].specializers) == 2
            @test gen.methods[1].specializers[1] === Object
        end
    end

    @testset "Create Only Method" begin
        @defmethod only_method(a::Object, b::Object) = "generic function"

        @test class_of(only_method) === GenericFunction
        @test class_of(class_of(only_method)) === Class
        @test only_method.name == :only_method
        @test only_method.lambda_list == [:a, :b]
        @test length(only_method.methods) == 1

        @test class_of(only_method.methods[1]) == MultiMethod            
        @test only_method.methods[1].generic_function === only_method
        @test length(only_method.methods[1].specializers) == 2
        @test only_method.methods[1].specializers[1] === Object
    end
end

@testset "Add" begin
    @defgeneric add(a, b)

    @defclass(ComplexNumber, [Object], [real, imag])

    c1 = new(ComplexNumber, real=1, imag=2)

    @defmethod add(a::ComplexNumber, b::ComplexNumber) = new(ComplexNumber, real=(a.real + b.real), imag=(a.imag + b.imag))

    @test_throws ErrorException add(1,2)
    @test_throws ArgumentError c1(1)

    c = add(c1, c1)
    @test class_of(c) == ComplexNumber
    @test c.real == 2
    @test c.imag == 4

    @testset "Meta Object tests" begin
        @test class_of(add) === GenericFunction
        @test GenericFunction.slots == [:name, :lambda_list, :methods]
        @test class_of(add.methods[begin]) === MultiMethod
        @test MultiMethod.slots == [:specializers, :procedure, :generic_function]
        @test add.methods[begin].generic_function === add
    end
    
    @testset "Test Effective method" begin
        @defmethod add(a::Object, b::Object) = println("Added Two Object")

        @test length(add.methods) == 2
        c = add(c1, c1)
        @test class_of(c) == ComplexNumber
        @test c.real == 2
        @test c.imag == 4
    end

    @testset "Call next method" begin
        @defmethod add(a::ComplexNumber, b::ComplexNumber) = begin
            call_next_method()
            call_next_method()
            BaseStructure(
                ComplexNumber,
                Dict(
                    :real=>a.real + b.real,
                    :imag=>a.imag + b.imag
                )
            )
        end
    
        @test length(add.methods) == 2
    
        result = @capture_out add(c1, c1)
        @test result == "Added Two Object\nAdded Two Object\n"
    end

    @testset "BuiltIn Classes" begin
        @test class_of(1) == "<BuiltInClass _Int64>"
        @test class_of("Foo") == "<BuiltInClass _String>"

        @defmethod add(a::_Int64, b::_Int64) = a + b
        @defmethod add(a::_String, b::_String) = a * b

        @test add(1, 3) == 4
        @test add("Foo", "Bar") == "FooBar"
    end
end

