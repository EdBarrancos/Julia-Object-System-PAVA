include("BaseStructure.jl")

export GenericFunction, MultiMethod, new_method, new_generic_function, generic_methods, method_specializers

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
        :direct_slots=>[:specializers, :procedure, :generic_function],
        :class_precedence_list=>[Object, Top],
        :slots=>[:specializers, :procedure, :generic_function]
    )
)

pushfirst!(getfield(MultiMethod, :slots)[:class_precedence_list], MultiMethod)

function (f::BaseStructure)(x...)
    check_for_polymorph(f, GenericFunction, ArgumentError)

    if length(x) != length(f.lambda_list)
        non_applicable_method(f, x)
    end

    apply_methods(f, compute_effective_method(f, x), 1, x)
end

function apply_methods(generic_function::BaseStructure, effective_method_list::Vector, target_method_index::Integer,args::Tuple)
    check_for_polymorph(generic_function, GenericFunction, ArgumentError)

    if isempty(effective_method_list) || target_method_index > length(effective_method_list)
        non_applicable_method(generic_function, args)
    end

    #= Needs improvement in case of multiple calls =#
    apply_method(target_method_index, args, effective_method_list, generic_function)
end

function apply_method(
    target_method_index::Integer, 
    args::Tuple, 
    methods::Vector, 
    generic_function::BaseStructure)

    check_for_polymorph(generic_function, GenericFunction, ArgumentError)
    check_for_polymorph(methods[target_method_index], MultiMethod, ArgumentError)

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
    check_for_polymorph(f, GenericFunction, ArgumentError)

    applicable_methods = filter(
        method -> is_method_applicable(method, x), 
        f.methods)

    return sort(applicable_methods, lt=is_method_more_specific)
end

function create_method(
    parent_generic_function::BaseStructure, 
    new_method::BaseStructure)

    check_for_polymorph(parent_generic_function, GenericFunction, ArgumentError)
    check_for_polymorph(new_method, MultiMethod, ArgumentError)

    if !isequal(
        length(parent_generic_function.lambda_list),
        length(new_method.specializers))

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

function new_generic_function(name::Symbol, lambda_list::Vector)
    return BaseStructure(
        GenericFunction,
        Dict(
            :name=>name,
            :lambda_list=>lambda_list,
            :methods=>[]
        )
    )
end

function new_method(
    generic_function, 
    name::Symbol, 
    lambda_list::Vector, 
    specializers::Vector,
    procedure)

    if isnothing(generic_function)
        generic_function = new_generic_function(name, lambda_list)
    end

    for i in range(1, length(specializers), step=1)
        if ismissing(specializers[i])
            specializers[i] = Top
        end
    end

    create_method(
        generic_function,
        BaseStructure(
            MultiMethod,
            Dict(
                :generic_function=>generic_function,
                :specializers=>specializers,
                :procedure=>procedure
            )
        )
    )

    return generic_function
end

#= This one needs to be here or it will create a ciclic dependency =#
non_applicable_method = new_method(
    nothing,
    :non_applicable_method,
    [:generic_function, :args],
    [GenericFunction, _Tuple],
    function (call_next_method, generic_function, args)
        error(
            "No applicable method for function ", 
            generic_function.name, 
            " with arguments ",  
            string(args))
    end
)

#= ###################### 2.15 Introspection ###################### =#
generic_methods(method::BaseStructure) = getfield(method, :slots)[:methods]
method_specializers(method::BaseStructure) = getfield(method, :slots)[:specializers]
#= #################### END 2.15 Introspection #################### =#
