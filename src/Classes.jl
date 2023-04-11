export class_name, class_direct_slots, class_slots, 
class_direct_superclasses, class_cpl, @defclass

class_name(class::BaseStructure) = getfield(class, :slots)[:name]
class_direct_slots(class::BaseStructure) = getfield(class, :slots)[:direct_slots]
class_slots(class::BaseStructure) = getfield(class, :slots)[:slots]
class_direct_superclasses(class::BaseStructure) = getfield(class, :slots)[:direct_superclasses]
class_cpl(class::BaseStructure) = getfield(class, :slots)[:class_precedence_list]

macro defclass(name, superclasses, slots, options...)
    target_name = QuoteNode(name)
    #= Calculate Class Precedence List =#
    #= Calculate Slots =#
    direct_slots_definition = []
    for slot in slots.args
        if typeof(slot) != Expr
            push!(direct_slots_definition, Slot(slot, missing))
        elseif slot.head == :vect
            new_slot = Slot(:missing, missing)

            for option in slot.args
                if typeof(option) != Expr
                    setfield!(new_slot, :name, option)
                elseif option.head == :(=)
                    if option.args[begin] == :reader
                        println("TODO, define reader")
                    elseif option.args[begin] == :writer
                        println("TODO, define writer")
                    elseif option.args[begin] == :initform
                        setfield!(new_slot, :initform, option.args[end])
                    else
                        new_slot = Slot(option.args[begin], option.args[end])
                    end
                end
            end

            push!(direct_slots_definition, new_slot)
        elseif slot.head == :(=)
            push!(direct_slots_definition, Slot(slot.args[begin], slot.args[end]))
        end
    end

    metaclass = Class
    for option in options
        if typeof(option) == Expr
            if option.head == :(=)
                if option.args[begin] == :metaclass
                    metaclass = option.args[end]
                end
            end
        end
    end

    return esc(
        quote 
            $name = BaseStructure(
                $metaclass,
                Dict(
                    :name=>$target_name,
                    :direct_superclasses=>length($superclasses) > 0 ? $superclasses : [Object],
                    :direct_slots=>$direct_slots_definition,
                    :class_precedence_list=>length($superclasses) > 0 ? $superclasses : [Object],
                    :slots=>$direct_slots_definition
                )
            )
            pushfirst!(getfield($name, :slots)[:class_precedence_list], $name)
            $name
        end
    )
end


#= @defmethod initialize(obj::Object, initargs) = begin
    for slot in keys(initargs)
        slots = getfield(obj, :slots)
        slots[slot] = initargs[slot]
        setfield!(obj, :slots, slots)
    end
end =#

@defmethod allocate_instance(class::Class) = begin
    slots = [slot.name for slot in class_slots(class)]
    return BaseStructure(
        class,
        Dict(zip(slots, [missing for i in class_slots(class)]))
    )
end

new(class; initargs...) = 
    let instance = allocate_instance(class)
        println(initargs)
        #initialize(instance, initargs)
        for slot in keys(initargs)
            slots = getfield(instance, :slots)
            slots[slot] = initargs[slot]
            setfield!(instance, :slots, slots)
        end
        instance
    end

#= 

c1 = BaseStructure(
        ComplexNumber,
        Dict(
            :real=>1,
            :imag=>2
        )
    )
=#

@defclass(ComplexNumber, [Object], [real, imag])
c1 = new(ComplexNumber, real=1, imag=2)
c1.real
c1.imag

