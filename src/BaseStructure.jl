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
    ))

Object = BaseStructure(
    nothing,
    Dict(
        :name=>:Object,
        :direct_superclasses=>[Top], 
        :direct_slots=>[],
        :class_precedence_list=>[Top],
        :slots=>[]
    ))

Class = BaseStructure(
    nothing,
    Dict(
        :name=>:Class,
        :direct_superclasses=>[Object], 
        :direct_slots=>[:name, :direct_superclasses, :class_precedence_list, :slots, :direct_subclasses, :direct_methods],
        :class_precedence_list=>[Object, Top],
        :slots=>[:name, :direct_superclasses, :class_precedence_list, :slots, :direct_subclasses, :direct_methods]
    ))

setfield!(Class, :class_of_reference, Class)
setfield!(Object, :class_of_reference, Class)
setfield!(Top, :class_of_reference, Class)

#= Generic Functions and Methods =#

GenericFunction = BaseStructure(
    Class,
    Dict(
        :name=>:GenericFunction,
        :direct_superclasses=>[], 
        :direct_slots=>[:lambda_list, :methods],
        :class_precedence_list=>[],
        :slots=>[:lambda_list, :methods]
    )
)

MultiMethod = BaseStructure(
    Class,
    Dict(
        :name=>:MultiMethod,
        :direct_superclasses=>[], 
        :direct_slots=>[:specializers, :procedure, :generic_function],
        :class_precedence_list=>[],
        :slots=>[:specializers, :procedure, :generic_function]
    )
)

class_of(class) = getfield(class, :class_of_reference)
