using JuliaObjectSystem
using Test

@testset "Class Options" begin
    @defclass(Person, [],
        [[name, reader=get_name, writer=set_name!],
        [age, reader=get_age, writer=set_age!, initform=0],
        [friend, reader=get_friend, writer=set_friend!]])
    
    @defclass(SuperInt, [_Int128],[])

    @testset "defclass Macro class Creation" begin
        @test class_of(Person) == Class
        @test Person.direct_superclasses == [Object]
        @test Person.name == :Person
        
        @test class_of(SuperInt) == Class
        @test SuperInt.direct_superclasses == [_Int128]
        @test SuperInt.name == :SuperInt
    end

    @testset "Slot Creation" begin
        @testset "No Slots" begin
            
        end

        @testset "Simple Slots" begin
            
        end

        @testset "Slots Initform" begin
            
        end
    end
end