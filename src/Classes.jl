export class_name, class_direct_slots, class_slots, 
class_direct_superclasses, class_cpl, @defclass


class_name(class::BaseStructure) = getfield(class, :slots)[:name]
class_direct_slots(class::BaseStructure) = getfield(class, :slots)[:direct_slots]
class_slots(class::BaseStructure) = getfield(class, :slots)[:slots]
class_direct_superclasses(class::BaseStructure) = getfield(class, :slots)[:direct_superclasses]
class_cpl(class::BaseStructure) = getfield(class, :slots)[:class_precedence_list]

macro defclass(name, superclasses, slots)
    target_name = QuoteNode(name)
    #= Calculate Class Precedence List =#
    #= Calculate Slots =#
    slots_definition = []
    for slot in slots.args
        if typeof(slot) != Expr
            push!(slots_definition, Slot(slot, missing))
        elseif slot.head == :vect
            new_slot = Slot(:missing, missing)

            for option in slot.args
                if typeof(option) != Expr
                    new_slot.name = option
                elseif option.head == :(=)
                    if option.args[begin] == :reader
                        println("TODO, define reader")
                    elseif option.args[begin] == :writer
                        println("TODO, define writer")
                    elseif option.args[begin] == :initform
                        new_slot.initForm = option.args[end]
                    else
                        new_slot = Slot(option.args[begin], option.args[end])
                    end
                end
            end

            push!(slots_definition, new_slot)
        elseif slot.head == :(=)
            push!(slots_definition, Slot(slot.args[begin], slot.args[end]))
        end
    end

    return esc(
        quote 
            $name = BaseStructure(
                Class,
                Dict(
                    :name=>$target_name,
                    :direct_superclasses=>length($superclasses) > 0 ? $superclasses : [Object],
                    :direct_slots=>$slots_definition,
                    :class_precedence_list=>length($superclasses) > 0 ? $superclasses : [Object],
                    :slots=>$slots_definition
                )
            )
            pushfirst!(getfield($name, :slots)[:class_precedence_list], $name)
            $name
        end
    )
end
