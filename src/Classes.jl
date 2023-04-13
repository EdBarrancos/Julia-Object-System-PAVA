export class_name, class_direct_slots, class_slots, 
class_direct_superclasses, class_cpl, allocate_instance,
compute_slots, compute_getter_and_setter, @defclass

class_name(class::BaseStructure) = getfield(class, :slots)[:name]
class_direct_slots(class::BaseStructure) = getfield(class, :slots)[:direct_slots]
class_slots(class::BaseStructure) = getfield(class, :slots)[:slots]
class_direct_superclasses(class::BaseStructure) = getfield(class, :slots)[:direct_superclasses]
class_cpl(class::BaseStructure) = getfield(class, :slots)[:class_precedence_list]

@defgeneric allocate_instance(class)

@defmethod allocate_instance(class::Class) = begin
    slots = [slot.name for slot in class_slots(class)]
    print(slots)
    return BaseStructure(
        class,
        Dict(zip(slots, [slot.initform for slot in class_slots(class)]))
    )
end

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

@defgeneric compute_cpl(class)
@defmethod compute_cpl(class::Class) = begin
    queue = copy(class_direct_superclasses(class))
    class_precedence_list_definition = [class]
    while !isempty(queue)
        superclass = popfirst!(queue)
        if superclass == Top
            continue;
        end
        push!(class_precedence_list_definition, superclass)
        for direct_superclass in superclass.direct_superclasses
            if !(direct_superclass in queue) && !(direct_superclass in class_precedence_list_definition)
                push!(queue, direct_superclass)
            end
        end
    end
    push!(class_precedence_list_definition, Top)
    return class_precedence_list_definition
end

macro defclass(name, superclasses, slots, options...)
    target_name = QuoteNode(name)
    #= Calculate Slots =#
    direct_slots_definition = []
    readers_writers= []
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
                        get = option.args[end]
                        read = slot.args[begin]
                        reader = 
                            quote
                                @defmethod $get(o::$name) = o.$read
                            end
                        push!(readers_writers, :($reader))
                    elseif option.args[begin] == :writer
                        set = option.args[end]
                        write = slot.args[begin]
                        writer = 
                            quote
                                @defmethod $set(o::$name, v) = o.$write = v
                            end
                        push!(readers_writers, :($writer))
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

    methods = Expr(:block, readers_writers...)

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
            $name = allocate_instance($metaclass)
            $name.name = $target_name
            $name.direct_superclasses = length($superclasses) > 0 ? $superclasses : [Object]
            $name.direct_slots = $direct_slots_definition
            $name.class_precedence_list = compute_cpl($name)
            $name.slots = compute_slots($name)
            $methods
            $name
        end
    )
end