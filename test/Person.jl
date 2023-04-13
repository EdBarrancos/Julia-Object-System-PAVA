using JuliaObjectSystem
using Test

@testset "Class Options" begin
    @defclass(AnotherClass, [Class],
        [name, direct_superclasses, 
        class_precedence_list, slots, 
        direct_subclasses])
    
    @defclass(Person, [],
        [[name, reader=get_name, writer=set_name!],
        [age, reader=get_age, writer=set_age!, initform=0],
        [friend, reader=get_friend, writer=set_friend!]],
        metaclass=AnotherClass)
    
    @defclass(SuperInt, [_Int128],[])

    @testset "defclass Macro class Creation" begin
        @test class_of(Person) == AnotherClass
        @test class_of(class_of(Person)) == Class
        @test Person.direct_superclasses == [Object]
        @test Person.name == :Person
        
        @test class_of(SuperInt) == Class
        @test SuperInt.direct_superclasses == [_Int128]
        @test SuperInt.name == :SuperInt
    end

    @testset "Slot Creation" begin
        @testset "No Slots" begin
            @test isempty(SuperInt.slots)
        end

        @testset "Simple Slots" begin
            @defclass(SuperInt, [_Int128],[value])
            @test getfield(SuperInt.slots[begin], :name) == :value
            @test ismissing(getfield(SuperInt.slots[begin], :initform))

            @defclass(SuperInt, [_Int128],[[value]])
            @test getfield(SuperInt.slots[begin], :name) == :value
            @test ismissing(getfield(SuperInt.slots[begin], :initform)) 
        end

        @testset "Slots Initform" begin
            @defclass(SuperInt, [_Int128],[value=2, isSuper=true])
            @test getfield(SuperInt.slots[begin], :name) == :value
            @test getfield(SuperInt.slots[begin], :initform) == 2
            @test getfield(SuperInt.slots[end], :name) == :isSuper
            @test getfield(SuperInt.slots[end], :initform) == true 

            @test getfield(Person.slots[begin], :name) == :name
            @test ismissing(getfield(Person.slots[begin], :initform))
            @test getfield(Person.slots[2], :name) == :age
            @test getfield(Person.slots[2], :initform) == 0
            @test getfield(Person.slots[3], :name) == :friend
            @test ismissing(getfield(Person.slots[3], :initform))
        end
    end
    
    @testset "Readers and Writers creation" begin

        p1 = BaseStructure(
            Person,
            Dict(
                :name=>missing,
                :age=>0,
                :friend=>""
            )
        )

        @test get_age(p1) == 0
        @test ismissing(get_name(p1))

        set_name!(p1, "Pessoa")
        @test get_name(p1) == "Pessoa"
    end

end