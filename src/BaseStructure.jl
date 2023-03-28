using Printf

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

class_of(class) = getfield(class, :class_of_reference)
