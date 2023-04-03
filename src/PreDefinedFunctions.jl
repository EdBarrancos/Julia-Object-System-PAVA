include("GenericFunctionAndMethods.jl")

export print_object

print_object = BaseStructure(
    GenericFunction,
    Dict(
        :name => :print_object,
        :lambda_list => [:obj],
        :methods => []
    )
)

new_method(
    print_object,
    :print_object,
    [:class],
    [Class],
    function (call_next_method, class)
        print("<" ,String(getfield(class, :class_of_reference).name), " ", String(class.name) , ">")
    end
)

new_method(
    print_object,
    :print_object,
    [:obj],
    [Object],
    function (call_next_method, obj)
        print("<",String(getfield(obj, :class_of_reference).name)," ", repr(UInt64(pointer_from_objref(obj))) * ">")
    end
)

new_method(
    print_object,
    :print_object,
    [:generic_func],
    [GenericFunction],
    function (call_next_method, gen)
        print(
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
    [:method],
    [MultiMethod],
    function (call_next_method, method)
        output_string = "<" * 
            String(getfield(method, :class_of_reference).name) *
            " " *
            String(method.generic_function.name)
        
        specializers = "("
        if length(method.specializers) > 0
            specializers *= String(method.specializers[begin].name)
        end

        for class in method.specializers[2:end]
            specializers *= ','
            specializers *= String(class.name)
        end
        specializers *= ")"

        output_string *= specializers * ">"
        print(output_string)
    end
)

function Base.show(io::IO, t::BaseStructure)
   print_object(t)
end