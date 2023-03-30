include("../GenericFunctionAndMethods.jl")
include("ComplexNumber.jl")

#= @defgeneric add(a, b) =#

add = BaseStructure(
    GenericFunction,
    Dict(
        :name=>:add,
        :lambda_list=>[:a, :b],
        :methods=>[]
    )
)

#= Goal: ERROR:Not a Function =#
c1(1)

#= Goal: ERROR: No applicable method for function add with arguments (1, 2) =#
add(1,2)

create_method(
    add,
    BaseStructure(
        MultiMethod,
        Dict(
            :lambda_list=>[:a, :b],
            :specializers=>[
                ComplexNumber, 
                ComplexNumber], 
            :procedure=> 
                quote
                    BaseStructure(
                        ComplexNumber,
                        Dict(
                            :real=>getfield(a, :slots)[:real] + getfield(b, :slots)[:real],
                            :imag=>getfield(a, :slots)[:imag] + getfield(b, :slots)[:imag]
                        )
                    )
                end, 
            :generic_function=>add
        )
    )
)

#= For testing =#
o1 = BaseStructure(
    Object,
    Dict()
)

#= Goal: ERROR: No applicable method for function add with arguments (1, 2) =#
add(o1, o1)

#= Working =#
c = add(c1, c1)
println()
getfield(class_of(c), :slots)[:name]
