export BaseStructure, Top, Object, Class, Slot, class_of, check_class, check_for_polymorph

mutable struct BaseStructure
    class_of_reference::Any #= Supposed to be another BaseStructure =#
    slots::Dict{Symbol, Any}
end

mutable struct Slot
    name::Symbol
    initForm::Any
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

setfield!(Class, :class_of_reference, Class)
setfield!(Object, :class_of_reference, Class)
setfield!(Top, :class_of_reference, Class)

class_of(instance::BaseStructure) = getfield(instance, :class_of_reference)

check_for_polymorph(instance, targetClass, exception) = begin
    if !(targetClass in class_of(instance).class_precedence_list)
        throw(exception("Given '" * String(targetClass.name) * "' is not a " * String(targetClass.name)))
    end
end

check_class(instance, targetClass, exception) = begin
    if class_of(instance) != targetClass
        throw(exception("Given '" * String(targetClass.name) * "' is not a " * String(targetClass.name)))
    end
end

function Base.getproperty(obj::BaseStructure, sym::Symbol)
    getfield(obj, :slots)[sym]
end

function Base.setproperty!(obj::BaseStructure, name::Symbol, x)
    slots = getfield(obj, :slots)
    slots[name] = x
    setfield!(obj, :slots, slots)
    x
end
