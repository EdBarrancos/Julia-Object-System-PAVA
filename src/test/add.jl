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
            :specializers=>[
                ComplexNumber, 
                ComplexNumber], 
            :procedure=>[], 
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

#= Returns the effective_methods for now =#
add(c1, c1)

