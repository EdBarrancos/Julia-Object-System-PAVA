include("../src/BaseStructure.jl")

# @defclass(Shape, [], [])
Shape = BaseStructure(
    Class,
    Dict(
        :name=>:Shape,
        :direct_superclasses=>[Object], 
        :direct_slots=>[],
        :class_precedence_list=>[Object, Top],
        :slots=>[]
    )
)
pushfirst!(Shape.class_precedence_list, Shape)

# @defclass(ComplexNumber, [], [real, imag])
ComplexNumber = BaseStructure(
        Class,
        Dict(
            :name=>:ComplexNumber,
            :direct_superclasses=>[Object], 
            :direct_slots=>[:real, :imag],
            :class_precedence_list=>[Object, Top],
            :slots=>[:real, :imag]
        )
    )
pushfirst!(getfield(ComplexNumber, :slots)[:class_precedence_list], ComplexNumber)

#= @defclass(Person, [],
  [[name, reader=get_name, writer=set_name!],
  [age, reader=get_age, writer=set_age!, initform=0],
  [friend, reader=get_friend, writer=set_friend!]],
  metaclass=UndoableClass)) =#

# check if the metaclass is defined, if not defined then define it
if !@isdefined UndoableClass
    # @defclass(UndoableClass, [], [])
    UndoableClass = BaseStructure(
        Class,
        Dict(
            :name=>:UndoableClass,
            :direct_superclasses=>[Object], 
            :direct_slots=>[],
            :class_precedence_list=>[Object, Top],
            :slots=>[]
        )
    )
end

Person = BaseStructure(
    UndoableClass,
    Dict(
        :name=>:Person,
        :direct_superclasses=>[Object], 
        :direct_slots=>[name, age, friend],
        :class_precedence_list=>[Object, Top],
        :slots=>[name, age, friend]
    )
)
pushfirst!(Person.class_precedence_list, Person)

#add readers and writers