using JuliaObjectSystem
using Test

@testset "All Tests" begin
    include("ComplexNumber.jl")
    include("add.jl")
    include("PrintObject_test.jl")
    include("MultipleDispatch.jl")
    include("MultipleInheritance.jl")
    include("Person.jl")
    include("defgeneric.jl")
    include("computeSlots.jl")
end
