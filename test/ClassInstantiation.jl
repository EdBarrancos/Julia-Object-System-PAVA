using JuliaObjectSystem
using Test

@defclass(CountingClass, [Class], [counter=0])
@defmethod allocate_instance(class::CountingClass) = begin
    class.counter += 1
    call_next_method()
end
@defclass(Foo, [], [], metaclass=CountingClass)
@defclass(Bar, [], [], metaclass=CountingClass)


@testset "Class Instantiation" begin
    new(Foo)
    new(Foo)
    new(Bar)
    @test Foo.counter == 2
    @test Bar.counter == 1
end
