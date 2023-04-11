export class_name, class_direct_slots, class_slots, 
class_direct_superclasses, class_cpl, compute_slots, compute_getter_and_setter,
@defclass

class_name(class::BaseStructure) = getfield(class, :slots)[:name]
class_direct_slots(class::BaseStructure) = getfield(class, :slots)[:direct_slots]
class_slots(class::BaseStructure) = getfield(class, :slots)[:slots]
class_direct_superclasses(class::BaseStructure) = getfield(class, :slots)[:direct_superclasses]
class_cpl(class::BaseStructure) = getfield(class, :slots)[:class_precedence_list]

@defgeneric compute_slots(class)

@defmethod compute_slots(class::Class) = begin
    return vcat(class.direct_slots, map((elem) -> elem.slots, class.direct_superclasses)...)
end

@defgeneric compute_getter_and_setter(class, slot_name)

@defmethod compute_getter_and_setter(class::Class, slot_name) = begin
    getter = (instance) -> return getfield(instance, :slots)[slot_name]
    setter = (instance, new_value) -> begin
        slot = getfield(instance, :slots)
        slot[slot_name] = new_value
        return setfield!(instance, :slots, slot)
    end
    return (getter, setter)
end

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
        if typeof(option) == Expr && option.head == :(=)
            if option.args[begin] == :metaclass
                metaclass = option.args[end]
            else
                error("Unrecognized option")
            end
        else
            error("Invalid Option Syntax. Example: @defclass(SuperHuman, [], [], metaclass=SuperMetaClass)")
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
                    :slots=>[]
                )
            )
            pushfirst!(getfield($name, :slots)[:class_precedence_list], $name)
            $name.slots = compute_slots($name)
            $name
        end
    )
end
