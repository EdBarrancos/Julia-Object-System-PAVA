export print_object

print_object = BaseStructure(
    GenericFunction,
    Dict(
        :name => :print_object,
        :lambda_list => [:io, :obj],
        :methods => []
    )
)

new_method(
    print_object,
    :print_object,
    [:io, :class],
    [_IO, Class],
    function (call_next_method, io, class)
        print(
            io, 
            "<" ,
            String(getfield(class, :class_of_reference).name), 
            " ", 
            String(class.name), 
            ">")
    end
)

new_method(
    print_object,
    :print_object,
    [:io, :obj],
    [_IO, Object],
    function (call_next_method, io, obj)
        print(
            io, 
            "<",
            String(getfield(obj, :class_of_reference).name),
            " ", 
            repr(UInt64(pointer_from_objref(obj))), 
            ">")
    end
)

new_method(
    print_object,
    :print_object,
    [:io, :generic_func],
    [_IO, GenericFunction],
    function (call_next_method, io, gen)
        print(
            io,
            "<", 
            String(getfield(gen, :class_of_reference).name), 
            " ", 
            gen.name, 
            " with ", 
            length(gen.methods),
            " methods>")
    end
)

new_method(
    print_object,
    :print_object,
    [:io, :method],
    [_IO, MultiMethod],
    function (call_next_method, io, method)
        print(io, "<")
        print(
            io,
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

        print(io, ")")

        print(io, ">")
    end
)

new_method(
    print_object,
    :print_object,
    [:io, :vector],
    [_IO, _Vector],
    function (call_next_method, io, vector)
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
)

new_method(
    print_object,
    :print_object,
    [:io, :tuple],
    [_IO, _Tuple],
    function (call_next_method, io, tuple)
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
)

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