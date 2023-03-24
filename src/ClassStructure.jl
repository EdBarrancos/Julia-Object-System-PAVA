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

Class.class_of_reference = Class
Object.class_of_reference = Class
Top.class_of_reference = Class

#= Next step: Hand define ComplexNumber =#

#= TODO:
    - Function to compute class_precedence_list
    - Way to get slots (slots = direct_slots + superclasses.slots)
        - Verify conflicts
    - Slot access (get_property)
    - class_of
    - Class Options
        - Define Metaclass
        - set reader
        - set writer
        - set init_form
    - print object (needs generic function and methods) 
    - auto generate getters and setters
    - Multiple inheritance
    - Built in classes
    - Introspection
        - class_name
        - class_direct_slots
        - class_slots
        - class_direct_superclasses
        - class_cpl (class_precedence_list)
    - new(...) 
    - Multiple metaclass inheritance =#
