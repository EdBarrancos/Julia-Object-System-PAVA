using JuliaObjectSystem
using Test

@defclass(FlavorsClass, [Class], [])
        
@defmethod compute_cpl(class::FlavorsClass) =
    let depth_first_cpl(class) =
        [class, foldl(vcat, map(depth_first_cpl, class_direct_superclasses(class)), init=[])...],
    base_cpl = [Object, Top]
    vcat(unique(filter(!in(base_cpl), depth_first_cpl(class))), base_cpl)
end

@testset "Class Precedence List" begin
    @defclass(A, [], [])
    @defclass(B, [], [])
    @defclass(C, [], [])
    @defclass(D, [A, B], [])
    @defclass(E, [A, C], [])
    @defclass(F, [D, E], [])

    @testset "Base class" begin
        result = A.class_precedence_list
        @test result == [A, Object, Top]
        result = B.class_precedence_list
        @test result == [B, Object, Top]
        result = C.class_precedence_list
        @test result == [C, Object, Top]
    end
    
    @testset "Direct SubClass" begin
        result = D.class_precedence_list
        @test result == [D, A, B, Object, Top]
        result = E.class_precedence_list
        @test result == [E, A, C, Object, Top]
    end 

    @testset "Higher SubClasses" begin
        result = F.class_precedence_list
        @test result == [F, D, E, A, B, C, Object, Top]
    end

    @testset "Compute CPL function on a existing class" begin
        result = compute_cpl(F)
        @test result == [F, D, E, A, B, C, Object, Top]
    end

    @testset "Override compute_cpl" begin 
        @defclass(A, [], [], metaclass=FlavorsClass)
        @defclass(B, [], [], metaclass=FlavorsClass)
        @defclass(C, [], [], metaclass=FlavorsClass)
        @defclass(D, [A, B], [], metaclass=FlavorsClass)
        @defclass(E, [A, C], [], metaclass=FlavorsClass)
        @defclass(F, [D, E], [], metaclass=FlavorsClass)

        result = compute_cpl(F)
        @test result == [F, D, A, B, E, C, Object, Top]   
    end    
end

