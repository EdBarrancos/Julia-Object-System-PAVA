include("BaseStructure.jl")


GenericFunction = BaseStructure(
    Class,
    Dict(
        :name=>:GenericFunction,
        :direct_superclasses=>[], 
        :direct_slots=>[:name, :lambda_list, :methods],
        :class_precedence_list=>[],
        :slots=>[:name, :lambda_list, :methods]
    )
)

MultiMethod = BaseStructure(
    Class,
    Dict(
        :name=>:MultiMethod,
        :direct_superclasses=>[], 
        :direct_slots=>[:specializers, :procedure, :generic_function],
        :class_precedence_list=>[],
        :slots=>[:specializers, :procedure, :generic_function]
    )
)

function (f::BaseStructure)(x...)
    if (getfield(f,:class_of_reference) != GenericFunction)
        error("Not a Function")
    end

    if length(x) != length(getfield(f, :slots)[:lambda_list])
        error("No applicable method for function ", String(getfield(f,:slots)[:name]), " with arguments ",  string(x))
    end

    effective_methods = compute_effective_method(f, x)
    if ismissing(effective_methods)
        error("No applicable method for function ", String(getfield(f,:slots)[:name]), " with arguments ",  string(x))
    end

    #= TODO: Call first method? =#
    return effective_methods
end

function is_method_applicable(method::BaseStructure, x) 
    for i in range(1, length(x) - 1)
        if !any(
                (elem) -> elem == getfield(method, :slots)[:specializers][i], 
                getfield(getfield(x[i], :class_of_reference),:slots)[:class_precedence_list]
            )

            return false
        end
    end

    return true
end

function is_method_more_specific(method1::BaseStructure, method2::BaseStructure)
end

function compute_effective_method(f::BaseStructure, x)
    if (getfield(f, :class_of_reference) != GenericFunction)
        error("Not a Function")
    end

    applicable_methods = filter(method -> is_method_applicable(method, x), getfield(f, :slots)[:methods])

    #= TODO: Compute the effective methods =#
    if length(applicable_methods) == 0
        return missing
    end

    return applicable_methods
end

function create_method(
    parent_generic_function::BaseStructure, 
    new_method::BaseStructure)

    #= TODO: Check if has some signature =#

    push!(getfield(parent_generic_function, :slots)[:methods], new_method)
end
