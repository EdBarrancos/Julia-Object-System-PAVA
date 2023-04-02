include("../BaseStructure.jl")
include("../GenericFunctionAndMethods.jl")

ComplexNumber = BaseStructure(
    Class,
    Dict(
        :name=>:ComplexNumber,
        :direct_superclasses=>[Object], 
        :direct_slots=>[:real, :imag],
        :class_precedence_list=>[Object],
        :slots=>[:real, :imag]
    )
)

pushfirst!(getfield(ComplexNumber, :slots)[:class_precedence_list], ComplexNumber)

c1 = BaseStructure(
    ComplexNumber,
    Dict(
        :real=>1,
        :imag=>2
    )
)

#= #################### 2.3 Slot Access #################### =#
#c1.slots[:real]
getproperty(c1, :real)
c1.real
setproperty!(c1, :imag, -1)
c1.imag += 3

class_of(c1) == ComplexNumber
class_of(class_of(c1)) == Class
#= #################### ENF 2.3 #################### =#


#= #################### 2.5 Pre-defined Generic Functions and Methods #################### =#

create_method(
    print_object,
    BaseStructure(
        MultiMethod,
        Dict(
            :lambda_list=>[:c],
            :specializers=>[ComplexNumber],
            :procedure=> function (call_next_method, c)
                    print("$(c.real)$(c.imag < 0 ? "-" : "+")$(abs(c.imag))i")
                end,
            :generic_function=>print_object
        )
    )
)

c1
#= ########################################################################################## =#

#= #################### 2.15 Introspection#################### =#
class_name(ComplexNumber)
class_direct_slots(ComplexNumber)
class_slots(ComplexNumber)
class_direct_superclasses(ComplexNumber)
class_cpl(ComplexNumber)
#= ########################################################################################## =#