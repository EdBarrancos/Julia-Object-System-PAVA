using Suppressor
using Test

@testset "Print object test" begin
    @testset "Print Instance" begin
        obj1 = BaseStructure(
            Object,
            Dict()
        )

        result = @capture_out show(obj1)
        @test result == "<Object " * repr(UInt64(pointer_from_objref(obj1))) * ">"
    end

    @testset "Print Classes" begin
        result = @capture_out show(Object)
        @test result = "<Class Object>"

        result = @capture_out show(Class)
        @test result = "<Class Class>"
    end
end