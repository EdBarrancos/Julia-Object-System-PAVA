export print_object, compute_cpl, non_applicable_method, new

@defgeneric print_object(obj, io)

@defmethod print_object(class::Class, io::_IO) = begin
    print(io, 
        "<" ,
        String(getfield(class, :class_of_reference).name), 
        " ", 
        String(class.name), 
        ">")
end

@defmethod print_object(obj::Object, io::_IO) = begin
    print(io, 
        "<",
        String(getfield(obj, :class_of_reference).name),
        " ", 
        repr(UInt64(pointer_from_objref(obj))), 
        ">")
end

@defmethod print_object(generic_func::GenericFunction, io::_IO) = begin
    print(io,
        "<", 
        String(getfield(generic_func, :class_of_reference).name), 
        " ", 
        generic_func.name, 
        " with ", 
        length(generic_func.methods),
        " methods>")
end

@defmethod print_object(method::MultiMethod, io::_IO) = begin
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

@defmethod print_object(vector::_Vector, io::_IO) = begin
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

@defmethod print_object(tuple::_Tuple, io::_IO) = begin
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
    print_object(t, io)
end

function Base.show(io::IO, t::Union{BaseStructure, Vector, Tuple})
    print_object(t, io)
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


@defmethod initialize(obj::Object, initargs::_Pairs) = begin
    slots = getfield(obj, :slots)
    for slot in keys(initargs)
        if !(slot in keys(slots))
            error("AttributeError: $(class_name(class_of(obj))) object has no attribute $slot")
        else
            slots[slot] = initargs[slot]
            setfield!(obj, :slots, slots)
        end
    end
end

@defmethod initialize(class::Class, initargs::_Pairs) = begin
    slots = getfield(class, :slots)
    for slot in keys(initargs)
        if !(slot in keys(slots))
            error("AttributeError: $(class_name(class_of(class))) object has no attribute $slot")
        else
            slots[slot] = initargs[slot]
            setfield!(class, :slots, slots)
        end
    end
end

@defmethod initialize(generic::GenericFunction, initargs::_Pairs) = begin
    slots = getfield(generic, :slots)
    for slot in keys(initargs)
        if !(slot in keys(slots))
            error("AttributeError: $(class_name(class_of(generic))) object has no attribute $slot")
        else
            slots[slot] = initargs[slot]
            setfield!(generic, :slots, slots)
        end
    end
end

@defmethod initialize(method::MultiMethod, initargs::_Pairs) = begin
    slots = getfield(method, :slots)
    for slot in keys(initargs)
        if !(slot in keys(slots))
            error("AttributeError: $(class_name(class_of(method))) object has no attribute $slot")
        else
            slots[slot] = initargs[slot]
            setfield!(method, :slots, slots)
        end
    end
end

new(class; initargs...) = 
    let instance = allocate_instance(class)
        initialize(instance, initargs)
        instance
    end