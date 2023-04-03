using Suppressor
using Test

@testset "Complex Number Creation" begin
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

    @test class_of(c1) === ComplexNumber
    @test class_of(class_of(c1)) === Class
    @test class_of(class_of(class_of(c1))) === Class

    @test getproperty(c1, :real) === c1.real
    @test c1.real == getfield(c1, :slots)[:real]

    @test getproperty(c1, :imag) === c1.imag
    @test c1.imag === getfield(c1, :slots)[:imag]

    imag_value = c1.imag
    c1.imag += 3
    @test c1.imag === imag_value + 3

    @testset "Printing Complex Numbers" begin
        new_method(
            print_object,
            :print_object,
            [:c],
            [ComplexNumber],
            function (call_next_method, c)
                print("$(c.real)$(c.imag < 0 ? "-" : "+")$(abs(c.imag))i")
            end
        )

        result = @capture_out show(c1)
        @test result == "1+5i"
    end 
end