using JuliaObjectSystem
using Suppressor
using Test

@testset "Create Method and Generic Functions" begin
    @testset "Create Generic Function and Method" begin
        gen = new_generic_function(:gen, [:a, :b])
        @test class_of(gen) == GenericFunction
        @test class_of(class_of(gen)) == Class
        @test gen.name == :gen
        @test gen.lambda_list == [:a, :b]
        @test length(gen.methods) == 0

        @testset "Method" begin
            new_method(
                gen,
                :gen,
                [:a, :b],
                [Object, Object],
                function (call_next_method, a, b)
                    "generic function"
                end
            )
    
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
        gen = new_method(
            nothing,
            :gen,
            [:a, :b],
            [Object, Object],
            function (call_next_method, a, b)
                "generic function"
            end
        )

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

@testset "Add" begin
    add = new_generic_function(:add, [:a, :b])

    ComplexNumber = BaseStructure(
        Class,
        Dict(
            :name=>:ComplexNumber,
            :direct_superclasses=>[Object], 
            :direct_slots=>[:real, :imag],
            :class_precedence_list=>[Object],
            :slots=>[:real, :imag]
        )
    )
    pushfirst!(getfield(ComplexNumber, :slots)[:class_precedence_list], ComplexNumber)

    c1 = BaseStructure(
        ComplexNumber,
        Dict(
            :real=>1,
            :imag=>2
        )
    )

    add = new_method(
        add, 
        :add, 
        [:a, :b], 
        [ComplexNumber, ComplexNumber], 
        function (call_next_method, a, b)
            BaseStructure(
                ComplexNumber,
                Dict(
                    :real=>a.real + b.real,
                    :imag=>a.imag + b.imag
                )
            )
        end
    )

    @test_throws ErrorException add(1,2)
    @test_throws ArgumentError c1(1)

    c = add(c1, c1)
    @test class_of(c) == ComplexNumber
    @test c.real == 2
    @test c.imag == 4
    
    @testset "Test Effective method" begin
        new_method(
            add,
            :add,
            [:a, :b],
            [Object, Object],
            function (call_next_method, a, b)
                println("Added Two Object")
            end
        )

        @test length(add.methods) == 2
        c = add(c1, c1)
        @test class_of(c) == ComplexNumber
        @test c.real == 2
        @test c.imag == 4
    end

    @testset "Call next method" begin
        new_method(
            add,
            :add,
            [:a, :b],
            [ComplexNumber, ComplexNumber],
            function (call_next_method, a, b)
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
        )
    
        @test length(add.methods) == 2
    
        result = @capture_out add(c1, c1)
        @test result == "Added Two Object\nAdded Two Object\n"
    end

end
