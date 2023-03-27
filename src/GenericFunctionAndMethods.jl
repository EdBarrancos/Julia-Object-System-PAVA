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
    effective_methods = compute_effective_method(f, x)
    if ismissing(effective_methods)
        error("No applicable method for function ", String(getfield(f,:slots)[:name]), " with arguments ",  string(x))
    end
end

compute_effective_method(f::BaseStructure, x...) = begin
    if (getfield(f,:class_of_reference) != GenericFunction)
        error("Not a Function")
    end

    #= TODO: Compute the effective methods =#
    return missing
end