include("BaseStructure.jl")

export _Int8, _Int16, _Int32, _Int128, _Bool, _Char, _String, _Float16, _Float32, _Float64, _Tuple, _Vector, class_of

new_built_in_type(name::Symbol) = begin
    newType = BaseStructure(
        Class,
        Dict(
            :name=>:name,
            :direct_superclasses=>[Top], 
            :direct_slots=>[],
            :class_precedence_list=>[Top],
            :slots=>[]
        )
    )

    pushfirst!(getfield(newType, :slots)[:class_precedence_list], newType)
    return newType
end

_Int8 = new_built_in_type(:_Int8)
_Int16 = new_built_in_type(:_Int16)
_Int32 = new_built_in_type(:_Int32)
_Int64 = new_built_in_type(:_Int64)
_Int128 = new_built_in_type(:_Int128)

_Bool = new_built_in_type(:_Bool)

_Char = new_built_in_type(:_Char)
_String = new_built_in_type(:_String)

_Float16 = new_built_in_type(:_Float16)
_Float32 = new_built_in_type(:_Float32)
_Float64 = new_built_in_type(:_Float64)

_Vector = new_built_in_type(:_Vector)
_Tuple = new_built_in_type(:_Tuple)

class_of(instance::Int8) = _Int8
class_of(instance::Int16) = _Int16
class_of(instance::Int32) = _Int32
class_of(instance::Int64) = _Int64
class_of(instance::Int128) = _Int128

class_of(instance::Bool) = _Bool

class_of(instance::Char) = _Char
class_of(instance::String) = _String

class_of(instance::Float16) = _Float16
class_of(instance::Float32) = _Float32
class_of(instance::Float64) = _Float64

class_of(instance::Vector) = _Vector
class_of(instance::Tuple) = _Tuple
