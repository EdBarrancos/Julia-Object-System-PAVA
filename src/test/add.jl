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
            :procedure=> function (call_next_method, a, b)
                    println("COMPLEX ADDING")
                    call_next_method()
                    call_next_method()
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

create_method(
    add,
    BaseStructure(
        MultiMethod,
        Dict(
            :lambda_list=>[:a, :b],
            :specializers=>[
                Object, 
                Object], 
            :procedure=> function (call_next_method, a, b)
                    println("CALL NEXT METHOD working")
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
#= Working =#
add(o1, o1)
c = add(c1, c1)
