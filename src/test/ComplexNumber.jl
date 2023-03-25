include("../BaseStructure.jl")

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

c1 = BaseStructure(
    ComplexNumber,
    Dict(
        :real=>1,
        :imag=>2
    )
)

c1.slots[:real]

class_of(c1) == ComplexNumber
class_of(class_of(c1)) == Class


#= print ComplexNumber:
    - <Metaclass class>  =#
@printf("<%s %s>",String(ComplexNumber.class_of_reference.slots[:name]),String(ComplexNumber.slots[:name]))

#= print c1:
    - <Class id> =#
@printf("<%s %s>",String(c1.class_of_reference.slots[:name]),"ID-PLACEHOLDER")