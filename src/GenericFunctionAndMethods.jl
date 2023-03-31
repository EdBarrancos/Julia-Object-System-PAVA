include("BaseStructure.jl")


GenericFunction = BaseStructure(
    Class,
    Dict(
        :name=>:GenericFunction,
        :direct_superclasses=>[Object], 
        :direct_slots=>[:name, :lambda_list, :methods],
        :class_precedence_list=>[Object, Top],
        :slots=>[:name, :lambda_list, :methods]
    )
)

pushfirst!(getfield(GenericFunction, :slots)[:class_precedence_list], GenericFunction)

MultiMethod = BaseStructure(
    Class,
    Dict(
        :name=>:MultiMethod,
        :direct_superclasses=>[Object], 
        :direct_slots=>[:specializers, :procedure, :generic_function, :lambda_list],
        :class_precedence_list=>[Object, Top],
        :slots=>[:specializers, :procedure, :generic_function]
    )
)

pushfirst!(getfield(MultiMethod, :slots)[:class_precedence_list], MultiMethod)

function (f::BaseStructure)(x...)
    check_class(f, GenericFunction)

    if length(x) != length(f.lambda_list)
        #= TODO: call generic_function non_applicable_method =#
        error("No applicable method for function ", f.name, " with arguments ",  string(x))
    end

    apply_methods(f, compute_effective_method(f, x), 1, x)
end

function apply_methods(generic_function::BaseStructure, effective_method_list::Vector, target_method_index::Integer,args::Tuple)
    check_class(generic_function, GenericFunction)

    if isempty(effective_method_list) || target_method_index > length(effective_method_list)
        #= TODO: call generic_function non_applicable_method =#
        error(
            "No applicable method for function ", 
            generic_function.name, 
            " with arguments ",  
            string(args))
    end

    #= Needs improvement in case of multiple calls =#
    apply_method(target_method_index, args, effective_method_list, generic_function)
end

function apply_method(
    target_method_index::Integer, 
    args::Tuple, 
    methods::Vector, 
    generic_function::BaseStructure)

    check_class(generic_function, GenericFunction)
    check_class(methods[target_method_index], MultiMethod)

    method = methods[target_method_index]


    let 
        call_next_method = () -> apply_methods(generic_function, methods, target_method_index + 1, args)

        return method.procedure(call_next_method, args...)
    end
end

function is_method_applicable(method::BaseStructure, x) 
    for i in range(1, length(x), step=1)
        if !any(
                (class) -> class === method.specializers[i],
                class_of(x[i]).class_precedence_list)
            return false
        end
    end

    return true
end

function is_method_more_specific(method1::BaseStructure, method2::BaseStructure)
    for i in range(1, length(method1.specializers), step=1)
        index_spec1 = findfirst(
            (class) -> class === method2.specializers[i],
            method1.specializers[i].class_precedence_list)

        index_spec2 = findfirst(
            (class) -> class === method1.specializers[i],
            method2.specializers[i].class_precedence_list)

        if isnothing(index_spec2)
            return true
        elseif isnothing(index_spec1)
            return false
        elseif index_spec1 != index_spec2
            return index_spec1 <= index_spec2 
        end
    end

    #= Their the same =#
    return true
end

function compute_effective_method(f::BaseStructure, x)
    check_class(f, GenericFunction)

    applicable_methods = filter(
        method -> is_method_applicable(method, x), 
        f.methods)

    return sort(applicable_methods, lt=is_method_more_specific)
end

function create_method(
    parent_generic_function::BaseStructure, 
    new_method::BaseStructure)

    check_class(parent_generic_function, GenericFunction)
    check_class(new_method, MultiMethod)

    if !isequal(
        length(parent_generic_function.lambda_list),
        length(new_method.lambda_list))

        #= TODO: call an appropriate generic function =#
        error("Method does not correspond to generic function's signature")
    end
    
    #= override =#
    filter!(
        (method) -> 
            !(isequal(
                new_method.specializers,
                method.specializers)),
        parent_generic_function.methods)
        
    push!(parent_generic_function.methods, new_method)
end
