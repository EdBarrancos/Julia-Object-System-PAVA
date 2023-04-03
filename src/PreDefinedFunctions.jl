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
        print("<",String(getfield(obj, :class_of_reference).name)," ", pointer_from_objref(obj))
    end
)

function Base.show(io::IO, t::BaseStructure)
   print_object(t)
end