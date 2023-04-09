using Test

@testset "defgeneric test" begin
    @defgeneric add(a,b)
    @test class_of(add) == GenericFunction
    @test isempty(add.methods)
    @test add.lambda_list == [:a, :b]
end