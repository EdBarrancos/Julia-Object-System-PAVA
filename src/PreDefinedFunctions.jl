export print_object, compute_slots, non_applicable_method

@defgeneric print_object(io, obj)

@defmethod print_object(io::_IO, class::Class) = begin
    print(io, 
        "<" ,
        String(getfield(class, :class_of_reference).name), 
        " ", 
        String(class.name), 
        ">")
end

@defmethod print_object(io::_IO, obj::Object) = begin
    print(io, 
        "<",
        String(getfield(obj, :class_of_reference).name),
        " ", 
        repr(UInt64(pointer_from_objref(obj))), 
        ">")
end

@defmethod print_object(io::_IO, generic_func::GenericFunction) = begin
    print(io,
        "<", 
        String(getfield(generic_func, :class_of_reference).name), 
        " ", 
        generic_func.name, 
        " with ", 
        length(generic_func.methods),
        " methods>")
end

@defmethod print_object(io::_IO, method::MultiMethod) = begin
    print(io,
        "<",
        String(getfield(method, :class_of_reference).name),
        " ",
        String(method.generic_function.name))
    
    print(io, "(")
    if length(method.specializers) > 0
        print(io, method.specializers[begin].name)
    end

    for elem in method.specializers[2:end]
        print(io, ", ")
        print(io, elem.name)
    end

    print(io, ")", ">")
end

@defmethod print_object(io::_IO, vector::_Vector) = begin
    print(io, "[")
    if length(vector) > 0
        print(io, vector[begin])
    end

    for elem in vector[2:end]
        print(io, ", ")
        print(io, elem)
    end

    print(io, "]")
end

@defmethod print_object(io::_IO, tuple::_Tuple) = begin
    print(io, "(")
    if length(tuple) > 0
        print(io, tuple[begin])
    end

    for elem in tuple[2:end]
        print(io, ", ")
        print(io, elem)
    end

    print(io, ")")
end

function Base.show(io::IO, ::MIME"text/plain", t::Union{BaseStructure, Vector, Tuple})
    print_object(io, t)
end

function Base.show(io::IO, t::Union{BaseStructure, Vector, Tuple})
    print_object(io, t)
end

function Base.show(io::IO, ::MIME"text/plain", t::Union{Slot})
    print(io, t.name)
end

function Base.show(io::IO, t::Union{Slot})
    print(io, t.name)
end

@defmethod non_applicable_method(generic_function::GenericFunction, args::_Tuple) = begin
    error(
        "No applicable method for function ", 
        generic_function.name, 
        " with arguments ",  
        string(args))
end

@defgeneric compute_slots(class)

@defmethod compute_slots(class::Class) = begin
    return vcat(class.direct_slots, map((elem) -> elem.slots, class.direct_superclasses)...)
end