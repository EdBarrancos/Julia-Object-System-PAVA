include("../GenericFunctionAndMethods.jl")

#= @defgeneric add(a, b) =#

add = BaseStructure(
    GenericFunction,
    Dict(
        :name=>:add,
        :lambda_list=>[:a, :b],
        :methods=>[]
    )
)

add(1,2)



