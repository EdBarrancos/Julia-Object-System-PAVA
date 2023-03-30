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
    if !(GenericFunction in getfield(
        class_of(f), 
        :slots)[:class_precedence_list])

        #= TODO: call an appropriate generic function =#
        error("Given 'generic function' is not a generic function")
    end

    if length(x) != length(getfield(f, :slots)[:lambda_list])
        #= TODO: call generic_function non_applicable_method =#
        error("No applicable method for function ", String(getfield(f,:slots)[:name]), " with arguments ",  string(x))
    end

    apply_methods(f, compute_effective_method(f, x), x)
end

function apply_methods(generic_function::BaseStructure, effective_method_list::Vector, args::Tuple)
    if !(GenericFunction in getfield(
        class_of(generic_function), 
        :slots)[:class_precedence_list])

        #= TODO: call an appropriate generic function =#
        error("Given 'generic function' is not a generic function")
    end
    
    if isempty(effective_method_list)
        #= TODO: call generic_function non_applicable_method =#
        error(
            "No applicable method for function ", 
            String(getfield(generic_function,:slots)[:name]), 
            " with arguments ",  string(args))
    end

    apply_method(popfirst!(effective_method_list), args, effective_method_list, generic_function)
end

function apply_method(
    method::BaseStructure, 
    args::Tuple, 
    next_methods::Vector, 
    generic_function::BaseStructure)

    if !(GenericFunction in getfield(
        class_of(generic_function), 
        :slots)[:class_precedence_list])

        #= TODO: call an appropriate generic function =#
        error("Given 'generic function' is not a generic function")
    end

    if !(MultiMethod in getfield(
        class_of(method), 
        :slots)[:class_precedence_list])

        #= TODO: call an appropriate generic function =#
        error("Given 'method' is not a method")
    end

    let
        call_next_method = () -> apply_methods(generic_function, next_methods, args)

        for i in range(1, length(getfield(method, :slots)[:lambda_list]), step=1)
            eval(
                Expr(
                    :(=), 
                    getfield(method, :slots)[:lambda_list][i], 
                    args[i]))
        end

        eval(getfield(method, :slots)[:procedure])
    end
end

function is_method_applicable(method::BaseStructure, x) 
    for i in range(1, length(x) - 1)
        if !any(
                ==(getfield(method, :slots)[:specializers][i]), 
                getfield(class_of(x[i]),:slots)[:class_precedence_list]
            )

            return false
        end
    end

    return true
end

function is_method_more_specific(method1::BaseStructure, method2::BaseStructure)
    for i in range(len(getfield(method1, :slots)[:specializers]))
        index_spec1 = findfirst(
            ==(getfield(method1, :slots)[:specializers][i]),
            getfield(getfield(method2, :slots)[:specializers], :class_precedence_list))

        index_spec2 = findfirst(
            ==(getfield(method2, :slots)[:specializers][i]),
            getfield(getfield(method1, :slots)[:specializers], :class_precedence_list))
        
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
    if !(GenericFunction in getfield(
        class_of(f), 
        :slots)[:class_precedence_list])

        #= TODO: call an appropriate generic function =#
        error("Given 'generic function' is not a generic function")
    end

    applicable_methods = filter(
        method -> is_method_applicable(method, x), 
        getfield(f, :slots)[:methods])

    return sort(applicable_methods, lt=is_method_more_specific)
end

function create_method(
    parent_generic_function::BaseStructure, 
    new_method::BaseStructure)

    if !(GenericFunction in getfield(
        class_of(parent_generic_function), 
        :slots)[:class_precedence_list])

        #= TODO: call an appropriate generic function =#
        error("Given 'generic function' is not a generic function")
    end

    if !(MultiMethod in getfield(
        class_of(new_method), 
        :slots)[:class_precedence_list])

        #= TODO: call an appropriate generic function =#
        error("Given 'method' is not a method")
    end

    if !isequal(
        length(getfield(new_method, :slots)[:lambda_list]),
        length(getfield(parent_generic_function, :slots)[:lambda_list]))

        #= TODO: call an appropriate generic function =#
        error("Method does not correspond to generic function's signature")
    end

    #= Supposedly there is never more than one repeated, but just in case =#
    overridden_methods = findall(
        (elem) -> isequal(
            getfield(new_method, :slots)[:specializers],
            getfield(elem, :slots)[:specializers]), 
        getfield(parent_generic_function, :slots)[:methods])
    
    filter!(
        (method) -> method in overridden_methods,
        getfield(parent_generic_function, :slots)[:methods])
        
    push!(getfield(parent_generic_function, :slots)[:methods], new_method)
end
