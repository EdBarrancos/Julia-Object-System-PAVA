#= This file is responsible for integrating the builin types of Julia in JOS =#
export _Int8, _Int16, _Int32, _Int64, _Int128, _Bool, _Char, _String, _Float16, _Float32, _Float64, _Tuple, _Vector, _Pairs, _Pair, _NamedTuple, class_of, _IO, _Symbol,
@defbuiltin

@defclass(BuiltInClass, [Class], [])

macro defbuiltin(typeDefinition) 
    if typeof(typeDefinition) != Expr
        error("Invalid macro signature. Example @defbuiltin _Int8(Int8)")
    end

    if typeDefinition.head != :call
        error("Invalid macro signature. Example @defbuiltin _Int8(Int8)")
    end

    return esc(quote
        @defclass($(typeDefinition.args[begin]), [Top], [], metaclass=BuiltInClass)
        class_of(instance::$(typeDefinition.args[end])) = $(typeDefinition.args[begin])
        $(typeDefinition.args[begin])
    end)
end

@defbuiltin _Int8(Int8)
@defbuiltin _Int16(Int16)
@defbuiltin _Int32(Int32)
@defbuiltin _Int64(Int64)
@defbuiltin _Int128(Int128)

@defbuiltin _Bool(Bool)

@defbuiltin _Char(Char)
@defbuiltin _String(String)

@defbuiltin _Float16(Float16)
@defbuiltin _Float32(Float32)
@defbuiltin _Float64(Float64)

@defbuiltin _Vector(Vector)
@defbuiltin _Tuple(Tuple)
@defbuiltin _Pair(Pair)
@defbuiltin _Pairs(Base.Pairs)
@defbuiltin _NamedTuple(NamedTuple)

@defbuiltin _IO(IO)

@defbuiltin _Symbol(Symbol)
