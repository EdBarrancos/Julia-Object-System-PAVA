export BaseStructure, Top, Object, Class, BuiltInClass, Slot, class_of, check_class, check_for_polymorph

mutable struct BaseStructure
    class_of_reference::Any #= Supposed to be another BaseStructure =#
    slots::Dict{Symbol, Any}
end

mutable struct Slot
    name::Symbol
    initform::Any
end

function Base.hash(one::Slot)
    return hash(one.name) + hash(one.initform)
end

function Base.:(==)(one::Slot, another::Slot)
    return one.name == another.name
end

function Base.:(==)(one::Symbol, another::Slot)
    return one == another.name
end

function Base.:(==)(one::Slot, another::Symbol)
    return one.name == another
end

Top = BaseStructure(
    nothing,
    Dict(
        :name=>:Top,
        :direct_superclasses=>[], 
        :direct_slots=>[],
        :class_precedence_list=>[],
        :slots=>[],
    )
)

pushfirst!(getfield(Top, :slots)[:class_precedence_list], Top)

Object = BaseStructure(
    nothing,
    Dict(
        :name=>:Object,
        :direct_superclasses=>[Top], 
        :direct_slots=>[],
        :class_precedence_list=>[Top],
        :slots=>[]
    )
)

pushfirst!(getfield(Object, :slots)[:class_precedence_list], Object)

Class = BaseStructure(
    nothing,
    Dict(
        :name=>:Class,
        :direct_superclasses=>[Object], 
        :direct_slots=>[
            Slot(:name, missing), 
            Slot(:direct_superclasses, missing), 
            Slot(:class_precedence_list, missing), 
            Slot(:slots, missing), 
            Slot(:direct_subclasses, missing)
        ],
        :class_precedence_list=>[Object, Top],
        :slots=>[
            Slot(:name, missing), 
            Slot(:direct_superclasses, missing), 
            Slot(:class_precedence_list, missing), 
            Slot(:slots, missing), 
            Slot(:direct_subclasses, missing)
        ]
    )
)

pushfirst!(getfield(Class, :slots)[:class_precedence_list], Class)

BuiltInClass = BaseStructure(
    nothing,
    Dict(
        :name=>:BuiltInClass,
        :direct_superclasses=>[Class], 
        :direct_slots=>[],
        :class_precedence_list=>[Object, Top],
        :slots=>[
            Slot(:name, missing), 
            Slot(:direct_superclasses, missing), 
            Slot(:class_precedence_list, missing), 
            Slot(:slots, missing), 
            Slot(:direct_subclasses, missing)
        ]
    )
)

pushfirst!(getfield(BuiltInClass, :slots)[:class_precedence_list], BuiltInClass)

setfield!(BuiltInClass, :class_of_reference, Class)
setfield!(Class, :class_of_reference, Class)
setfield!(Object, :class_of_reference, Class)
setfield!(Top, :class_of_reference, Class)

class_of(instance::BaseStructure) = getfield(instance, :class_of_reference)

check_for_polymorph(instance, targetClass, exception) = begin
    if !(targetClass in getfield(class_of(instance), :slots)[:class_precedence_list])
        throw(exception("Given '" * String(getfield(targetClass, :slots)[:name]) * "' is not a " * String(getfield(targetClass, :slots)[:name])))
    end
end

check_class(instance, targetClass, exception) = begin
    if class_of(instance) != targetClass
        throw(exception("Given '" * String(getfield(targetClass, :slots)[:name]) * "' is not a " * String(getfield(targetClass, :slots)[:name])))
    end
end

#= function Base.getproperty(obj::BaseStructure, sym::Symbol)
    print("ola1")
    getfield(obj, :slots)[sym]
end

function Base.setproperty!(obj::BaseStructure, name::Symbol, x)
    slots = getfield(obj, :slots)
    slots[name] = x
    setfield!(obj, :slots, slots)
    x
end
 =#