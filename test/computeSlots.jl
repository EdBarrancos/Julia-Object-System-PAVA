using JuliaObjectSystem
using Test

@defclass(AvoidCollisionsClass, [Class], [])

@defmethod compute_slots(class::AvoidCollisionsClass) =
    let slots = call_next_method(),
        duplicates = symdiff(slots, unique(slots))
        isempty(duplicates) ?
        slots :
        error("Multiple occurrences of slots: $(join(map(string, duplicates), ", "))")
    end

@testset "Compute Slots" begin
    @testset "No Conflicts" begin
        @defclass(A, [], [a, b])
        @defclass(B, [A], [c])

        @test compute_slots(B) == [:c, :a, :b]
    end

    @testset "With Conflicts" begin
        @defclass(A, [], [a, b])
        @defclass(B, [A], [c, a])

        @test compute_slots(B) == [:c, :a, :a, :b]
    end

    @testset "Overriding Compute Slots" begin
        @defclass(A, [], [a, b])
        @defclass(B, [], [a, c])
        @test_throws ErrorException @defclass(C, [A, B], [d], metaclass=AvoidCollisionsClass)
    end
end


