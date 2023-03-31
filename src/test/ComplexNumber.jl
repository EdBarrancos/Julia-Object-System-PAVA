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
#= #################### ENFD 2.3 #################### =#

#= print ComplexNumber:
    - <Metaclass class>  =#
@printf("<%s %s>",String(class_of(ComplexNumber).name),String(ComplexNumber.name))

#= print c1:
    - <Class id> =#
@printf("<%s %s>",String(getfield(c1, :class_of_reference).name),"ID-PLACEHOLDER")

Class.slots
ComplexNumber.name
ComplexNumber.direct_superclasses == [Object]
