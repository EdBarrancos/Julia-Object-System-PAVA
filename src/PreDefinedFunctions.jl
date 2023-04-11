export print_object, compute_cpl

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


@defgeneric compute_cpl(class)

@defmethod compute_cpl(class::Class) = begin 
    queue = copy(class_direct_superclasses(class))
    class_precedence_list_definition = []
    while !isempty(queue)
        superclass = popfirst!(queue) 
        push!(class_precedence_list_definition, superclass)
        for direct_superclass in superclass.direct_superclasses
            if !(direct_superclass in queue) 
                push!(queue, direct_superclass)
            end
        end
    end
    return class_precedence_list_definition
end