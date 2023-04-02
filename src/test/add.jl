using Test

include("../GenericFunctionAndMethods.jl")
include("ComplexNumber.jl")

#= @defgeneric add(a, b) =#

add = new_generic_function(:add, [:a, :b])

add = new_method(
    add, 
    :add, 
    [:a, :b], 
    [ComplexNumber, ComplexNumber], 
    function (call_next_method, a, b)
        println("COMPLEX ADDING")
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

o1 = BaseStructure(
    Object,
    Dict()
)

#= non_applicable_method =#
add(o1, o1)

add = new_method(
    add,
    :add,
    [:a, :b],
    [Object, Object],
    function (call_next_method, a, b)
        println("CALL NEXT METHOD")
    end
)

@test length(add.methods) == 2

add = new_method(
    add,
    :add,
    [:a, :b],
    [Object, Object],
    function (call_next_method, a, b)
        println("CALL NEXT METHOD")
    end
)

#= Testing override =#
@test length(add.methods) == 2

c = add(c1, c1)
@test class_of(c) == ComplexNumber
@test c.real == 2
@test c.imag == 4

#= Goal: ERROR:Not a Function =#
@test_throws ArgumentError c1(1)

#= Goal: ERROR: No applicable method for function add with arguments (1, 2) =#
@test_throws ErrorException add(1,2)
