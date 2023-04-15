using JuliaObjectSystem
using Suppressor
using Test

undo_trail = []
store_previous(object, slot, value) = push!(undo_trail, (object, slot, value))
current_state() = length(undo_trail)
restore_state(state) =
while length(undo_trail) != state
    restore(pop!(undo_trail)...)
end
save_previous_value = true
restore(object, slot, value) =
    let previous_save_previous_value = save_previous_value
        global save_previous_value = false
        try
            setproperty!(object, slot, value)
        finally
            global save_previous_value = previous_save_previous_value
        end
    end
@defclass(UndoableClass, [Class], [])

@defmethod compute_getter_and_setter(class::UndoableClass, slot) = begin
    print("ola\n")
    let (getter, setter) = call_next_method()
        (getter,
         (o, v)->begin
                if save_previous_value
                    store_previous(o, slot, getter(o))
                end
                setter(o, v)
                end)
    end
end

@defclass(Person, [], [name, age, friend], metaclass=UndoableClass)

@defmethod print_object(p::Person, io::_IO) =
    print(io, "[$(p.name), $(p.age)$(ismissing(p.friend) ? "" : " with friend $(p.friend)")]")

    @testset "Slot Access Protocol" begin
    p0 = new(Person, name="John", age=21)
    p1 = new(Person, name="Paul", age=23)
    p1.friend = p0
    println(p1)
    result = @capture_out show(p1)
    @test result == "[Paul, 23 with friend [John, 21]]"
    
    state0 = current_state()
    p0.age = 53
    p1.age = 55
    p0.name = "Louis"
    p0.friend = new(Person, name="Mary", age=19)
    result = @capture_out show(p1)
    @test result == "[Paul, 55 with friend [Louis, 53 with friend [Mary, 19]]]"

    state1 = current_state()
    p1.age = 70
    p1.friend = missing
    result = @capture_out show(p1)
    @test result == "[Paul, 70]"

    restore_state(state1)
    result = @capture_out show(p1)
    @test result == "[Paul, 55 with friend [Louis, 53 with friend [Mary, 19]]]"

    restore_state(state0)
    result = @capture_out show(p1)
    @test result == "[Paul, 23 with friend [John, 21]]"

end