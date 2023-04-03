export BaseStructure, Top, Object, Class, class_of, check_class, check_for_polymorph, 
class_name, class_direct_slots, class_slots, class_direct_superclasses, class_cpl

mutable struct BaseStructure
    class_of_reference::Any #= Supposed to be another BaseStructure =#
    slots::Dict{Symbol, Any}
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
        :direct_slots=>[:name, :direct_superclasses, :class_precedence_list, :slots, :direct_subclasses, :direct_methods],
        :class_precedence_list=>[Object, Top],
        :slots=>[:name, :direct_superclasses, :class_precedence_list, :slots, :direct_subclasses, :direct_methods]
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

#= #################### 2.3 Slot Access / 2.6 MetaObjects #################### =#
function Base.getproperty(obj::BaseStructure, sym::Symbol)
    getfield(obj, :slots)[sym]
end

function Base.setproperty!(obj::BaseStructure, name::Symbol, x)
    slots = getfield(obj, :slots)
    slots[name] = x
    setfield!(obj, :slots, slots)
    x
end

#= #################### END 2.3 Slot Access #################### =#

#= ###################### 2.15 Introspection ###################### =#
class_name(class::BaseStructure) = getfield(class, :slots)[:name]
class_direct_slots(class::BaseStructure) = getfield(class, :slots)[:direct_slots]
class_slots(class::BaseStructure) = getfield(class, :slots)[:slots]
class_direct_superclasses(class::BaseStructure) = getfield(class, :slots)[:direct_superclasses]
class_cpl(class::BaseStructure) = getfield(class, :slots)[:class_precedence_list]
#= #################### END 2.15 Introspection #################### =#
