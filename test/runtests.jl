using JuliaObjectSystem
using Test

@testset "All Tests" begin
    include("ComplexNumber.jl")
    include("add.jl")
    include("PrintObject_test.jl")
    include("MultipleDispatch.jl")
    include("MultipleInheritance.jl")
end
