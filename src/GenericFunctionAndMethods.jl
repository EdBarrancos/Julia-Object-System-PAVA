#= This file is responsible for defining generic function, method and related functions and how to deal with function calls=#
export GenericFunction, MultiMethod, 
generic_methods, method_specializers, create_method,
@defgeneric, @defmethod

GenericFunction = BaseStructure(
    Class,
    Dict(
        :name=>:GenericFunction,
        :direct_superclasses=>[Object], 
        :direct_slots=>[
            Slot(:name, missing), 
            Slot(:lambda_list, missing), 
            Slot(:methods, missing)
        ],
        :class_precedence_list=>[Object, Top],
        :slots=>[
            Slot(:name, missing), 
            Slot(:lambda_list, missing), 
            Slot(:methods, missing)
        ]
    )
)

pushfirst!(getfield(GenericFunction, :slots)[:class_precedence_list], GenericFunction)

MultiMethod = BaseStructure(
    Class,
    Dict(
        :name=>:MultiMethod,
        :direct_superclasses=>[Object], 
        :direct_slots=>[
            Slot(:specializers, missing), 
            Slot(:procedure, missing), 
            Slot(:generic_function, missing)
        ],
        :class_precedence_list=>[Object, Top],
        :slots=>[
            Slot(:specializers, missing), 
            Slot(:procedure, missing), 
            Slot(:generic_function, missing)
        ]
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

function is_method_more_specific(method1::BaseStructure, method2::BaseStructure, lambda)
    for i in range(1, length(lambda), step=1)
        index_spec1 = findfirst(
            (class) -> class === method1.specializers[i],
            class_of(lambda[i]).class_precedence_list)

        index_spec2 = findfirst(
            (class) -> class === method2.specializers[i],
            class_of(lambda[i]).class_precedence_list)

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

    return sort(applicable_methods, lt=(method1, method2) -> is_method_more_specific(method1, method2, x))
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
        
    pushfirst!(parent_generic_function.methods, new_method)
end

macro defgeneric(function_call)
    if typeof(function_call) != Expr
        error("Invalid syntax for defining generic function. Example: @defgeneric print_object(obj, io)")
    end

    if function_call.head != :call
        error("Invalid syntax for defining generic function. Example: @defgeneric print_object(obj, io)")
    end

    target_name = QuoteNode(function_call.args[begin])

    lambda_list = []
    if typeof(function_call.args[end]) == Expr && function_call.args[end].head == :(...)
        lambda_list = [lambda for lambda in function_call.args[end].args[begin]]
    else
        lambda_list = [lambda for lambda in function_call.args[2:end]]
    end

    return esc(
        quote
            $(function_call.args[begin]) = BaseStructure(
                GenericFunction,
                Dict(
                    :name=>$target_name,
                    :lambda_list=>$(lambda_list),
                    :methods=>[]
                )
            )
        end
    )
end

macro defmethod(method)
    if typeof(method) != Expr
        error("Invalid syntax for defining method. Example: @defmethod hello() = println(\"Hello\")")
    end

    if method.head != :(=)
        error("Missing body in method definition. Example: @defmethod hello() = println(\"Hello\")")
    end

    if typeof(method.args[begin]) != Expr && methpd.args[begin].head != :call
        error("Invalid syntax for defining method signature. Example: @defmethod hello() = println(\"Hello\")")
    end

    if typeof(method.args[end]) != Expr && methpd.args[end].head != :block
        error("Invalid syntax for defining method body. Example: @defmethod hello() = println(\"Hello\")")
    end

    lambda_list = []

    specializers = []

    for lambda in method.args[begin].args[2:end]
        if typeof(lambda) == Symbol
            push!(lambda_list, lambda)
            push!(specializers, Top)
        elseif lambda.head == :(::)
            push!(lambda_list, lambda.args[begin])
            push!(specializers, lambda.args[end])
        else
            error("Invalid syntax for method lambda_list. Example @defmethod add(a::ComplexNumber, b::ComplexNumber) = ...")
        end
    end

    lambda_list = Tuple(lambda_list)

    return esc(quote
        if ! @isdefined $(method.args[begin].args[begin])
            @defgeneric $(method.args[begin].args[begin])($(lambda_list)...)
        end
        
        #= Maybe we shouldn't be calling the function? =#
        create_method(
            $(method.args[begin].args[begin]),
            BaseStructure(
                MultiMethod,
                Dict(
                    :generic_function=>$(method.args[begin].args[begin]),
                    :specializers=>[$(specializers...)],
                    :procedure=>(call_next_method, $(lambda_list...))->$(method.args[end])
                )
            )
        )

        $(method.args[begin].args[begin])
    end)
end


#= ###################### 2.15 Introspection ###################### =#
generic_methods(method::BaseStructure) = getfield(method, :slots)[:methods]
method_specializers(method::BaseStructure) = getfield(method, :slots)[:specializers]
#= #################### END 2.15 Introspection #################### =#
