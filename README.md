# Julia-Object-System

## Description

JOS (Julia Object System) is an extension to the Julia Programming language that supports classes and metaclasses, multiple inheritance and generic functions with multiple-dispatch methods.

The implementation should follow the way those ideas were implemented in CLOS, in particular, in what regards the CLOS MOP.

## Info

This project was made for the course "Advanced Programming" by:

- Eduardo Barrancos
- Juliana Yang
- Xin Zheng
- Miguel Faria

## Development

### Doubts

- [x] What should be the result of `class_of(class_of(draw))`?
  - Class
- [x] Check if `class_of` is correctly implemented
- [x] What should appear if someone tries to call an instance as if it was a function?
  - We do not need to worry about it too much. But, currently, we are throwing a "Not a function" error, which is fine
- [x] Do Generic Functions and MultiMethods have super classes? Top?
  - No need. At best Object
- [x] How to deal with methods with the same signature
  - Redefine them
- [x] Result of calling `call_next_method()` when there is no next method to call?
  - Error
- [x] Which types do we need to support with the built in types? For example, do we need to support Unsigned ints?
  - Os referidos no enunciado e explicar como se cria um novo na apresentacao
- [x] 2.16.3 Slot Access `The generic function must return a tuple of non-generic functions` -> Methods or Julia regular functions?
  - Julia functions
- [x] Metaobject for slot definition?
  - Olhar para CLOS
- [x] Do we deliver the `test` module too?
  - Tudo

### Current State

- [x] x Tests
- [ ] 2.0 Macros
  - [x] 2.0.1 defclass [Not complete yet]
  - [x] 2.0.2 defgeneric
  - [x] 2.0.3 defmethod
    - [ ] Change defmethod so we can more easily define empty methods *Extra*
  - [x] 2.0.4 defbuiltin
- [x] 2.1 Classes
- [x] 2.2 Instances
- [x] 2.3 Slot Access
- [x] 2.4 Generic Functions and methods
- [x] 2.5 Pre-defined Generic Functions and Methods
- [x] 2.6 MetaObjects
- [x] 2.7 Class Options
- [x] 2.8 Readers and Writers
- [x] 2.9 Generic Function Calls
- [x] 2.10 Multiple Dispatch
- [ ] 2.11 Multiple Inheritance - **Juliana Testes**
- [x] 2.12 Class Hierarchy
- [x] 2.13 Class Precedence List
- [x] 2.14 Built-In Classes
- [x] 2.15 Introspection
- [ ] 2.16 Meta-Object Protocols
  - [ ] 2.16.1 Class Instantiation Protocol - **Juliana**
  - [x] 2.16.2 The Compute Slots Protocol
  - [x] 2.16.3 Slot Access Protocol
  - [x] 2.16.4 Class Precedence List protocol
- [ ] 2.17 Multiple Meta-Class Inheritance - **Liliana Testes**
- [ ] 2.18 *Extensions*
  - [ ] 2.18.1 Meta-Objects for slot definitions
  - [ ] 2.18.2 CLOS-like method combination for generic functions
  - [ ] 2.18.3 CLOS or Dylan's strategy for computing the class precedence list
  - [ ] 2.18.4 Additional Metaobject protocols

### Edu - Notes

#### Presentation Notes

##### BaseStructure

`BaseStructure` is the main struct of the project and its cornerstone. The goal of it is that every instance is our JOS is, behind the scenes, an instanciation of this struct.

```Julia
mutable struct BaseStructure
    class_of_reference::Any
    slots::Dict{Symbol, Any}
end
```

The `class_of_reference` field simulates the relationship between an instance and its class. A relation present all over the object system. E.g. the class ComplexNumber. For an instance of this class , for example "1+2i", the `class_of_reference` field points to ComplexNumber (which is also an instanciation of `BaseStructure`). For ComplexNumber, its `class_of_reference` field points to Class. Every class is a class of Class including itself.

The `slots` field will then hold any information and properties of the object/class/instance/function/...

##### Slot

Every class has slots, a entry in the field `slots` named "slots" (confunsing, i'm sorry). Instanciations of that class will have an entry on its field `slots` for each entry in the class's slots.

For example:

We have the ComplexNumber class:

```Julia
ComplexNumber = BaseStructure{
    Class,
    Dict(
        ...,
        slots=>[:real, :imag]
    )
}
```

Instances of ComplexNumber will look like:

```Julia
c1 = BaseStructure(
    ComplexNumber,
    Dict(
        :real=>1,
        :imag=>2
    )
)
```

In order to assign initial values to slots we created a second struct.

```Julia
mutable struct Slot
    name::Symbol
    initform::Any
end
```

##### Object, Top and Class

With the structs `BaseStructure` and `Slot` as our building blocks we can start creating the base of the class hierarcky. Every class is an Instance of the Class class, including itself. And every class is subclass of Object and as a consequence Top (except for built in classes which only inherit from Top and not Object).

However, these have to be built in parts as each depend on each other.

##### Generic Funtions and Methods

Generic Functions and Methods are both built using `BaseStructure`, both inherit from Object and are both classes of Class.

```Julia
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
```

Generic functions work as containers for methods. When we create a method we can specify its specializers and, when a call is made, the methods are ordered by specifity.

That allows us to use the `call_next_method` function to call the next method in the specialization order. This is injected into the arguments body so it can be used easily.

#### ClassStructure - 24-03

I defined a `BaseStructure` struct. The idea is that everything is an instance of `BaseStructure`

It has two fields. One for a reference to another `BaseStructure` which represents the connection of `class_of`. And another for slots, mapping a symbol to a value. This will vary depending on what we are creating.

Then I defined, Top, Object and Class (Base Metaclass) and created the circular relations between those.

In the next step I will try to create, by hand (without a macro), the ComplexNumber class

#### Calling Generic Functions

I did the base structure for us to be able to use BaseStructures as function, for us, in this case, GenericFunctions

It checks if the BaseStructure is of the class `GenericFunction`. Then it also verifies the number of arguments. Finally it computes the effective_method.

First it filters out non-applicable methods (by going through the arguments and their class precedence list and checking if it matches the method's specializer)

Then we arrange the remaining methods in more specific order

#### 2.4 - Generic Functions and Methods

There are some stuff I will leave to be done, as there are further along that address those issues, plus I want you to have access to what I've been doing quickly, so that the branch doesn't diverge too much.

I can handle these following issues next, weither how, I'll leave a note of the issues to be resolved here:

- [x] At the end of the generic function call, we need to call the first most specific method (first on the `effective_methods` list). For this, we may need to inject an extra argument to a method when we define it (the rest of the list). **Addressed in: 2.9 Generic Function Calls**
- [x] When the called function does not have any applicable method to the arguments given. Currently Im just throwing an error, but we need to call the generic function *non_applicable_method*. **Addressed in: 2.9 Generic Function Calls**

#### 2.9 - Generic Function Calls

Quick sum up. To call a generic function, we compute the effective method list (Done in the 2.4). Then we need to apply the first method. To apply a method, we need to first bind the arguments to variable names, next we need to bind the `call_next_method` function and finally run the methods body.

##### Extra TODOs

- [x] Make a function to verify if the argument is of the correct type or throw error
- [x] Make access methods
- [x] Test `call_next_method`
- [x] Make a test module

#### 2.4 - Built-In Classes

Really simple. Just an override of the `class_of` that, if it is called with one of Julia's built in types it returns the corresponding JOS class.

I've made for Ints, Floats, Bool, Char, String, Vector and Tuple. We may need to add more in the future if we need it.

##### Possible Improvements

We can't specialize based on the type inside the Vector

#### Tests

Had to play around a bit with the folder structure of the project. Ours wasn't well configurated.

Moved the `\test` folder to the root one. Added the `Project.toml` and `Manifesto.toml` (Auto generated).

Made JuliaObjectSystem into a module. And created the file `runtests.jl` that imports that module and runs the tests.

##### How to run tests

- Simple run the file `runtests.jl`
- Or run it on the terminal (Its way cooler ;) )
  - type `julia` then `]`
  - Something like `(JuliaObjectSystem) pkg>` should be appearing on your terminal
  - Then type `test`
  - If this not work, please tell me for me to improve this and try this:
    - `activate .`
    - **Try Again or:**
    - `add Test`
    - **Try Again or:**
    - `test JuliaObjectSystem`
    - **If all of this does not work, send me a message (@Eduardo)**

##### Adding new tests

Add a file in the `\test` folder. In the `runtests.jl` include the new file.
Try to use `@testset` to organize it.

#### 2.10 Multiple Dispatch

Done. Simply works. Beautiful

#### 2.7 Class Options

In order to do the class options I started creating the `defclass` macro. Although it is still incomplete. It does not compute the class_precedence_list, the full slot list and setting readers and writers for slots.

Also, restrucutred the slot section. As now we need to store initforms. And so i created a new struct `Slot` that holds a name and a init value. This new value will be used later on when we need to create new instances of classes.

Some classes don't really need this new Slot (e.g. `Class`, `GenericFunction` and `MultiMethod`) as all new instances default to missing and require a value. But I added it anyway for consistency.

I also overridden the `show` for `Slot` to show only the slot name.

##### 2.7 - Creating Slots

There are different type of slot definitions and so the macro needs todeal with them.

|ID|Actual|Result|
|---|---|---|
|0|`[hello]`|Creates the slot `hello` with initform as `missing`|
|1|`[hello=1]`|Creates the slot `hello` with initform as `1`|
|2|`[[hello]]`|Creates the slot `hello` with initform as `missing`|
|3|`[[hello=1]]`|Creates the slot `hello` with initform as `1`|
|4|`[[hello, initform=5]]`|Creates the slot `hello` with initform as `5`|

Code that gives us the intended result by id:
**0**

```Julia
if typeof(slot) != Expr
     push!(direct_slots_definition, Slot(slot, missing))
```

**1**

```Julia
if typeof(slot) != Expr
    ...
elseif 
  ...
elseif slot.head == :(=)
    push!(direct_slots_definition, Slot(slot.args[begin], slot.args[end]))
end
```

**2**

```Julia
if typeof(slot) != Expr
    ...
elseif slot.head == :vect
    new_slot = Slot(:missing, missing)

    for option in slot.args
        if typeof(option) != Expr
            setfield!(new_slot, :name, option)
        ...
        end
    end

    push!(direct_slots_definition, new_slot)
...
end
```

**3**

```Julia
if typeof(slot) != Expr
    ...
elseif slot.head == :vect
    new_slot = Slot(:missing, missing)

    for option in slot.args
        if typeof(option) != Expr
            setfield!(new_slot, :name, option)
        elseif option.head == :(=)
            if option.args[begin] == ...
                ...
            elseif option.args[begin] == ...
                ...
            elseif option.args[begin] == ...
                ...
            else
                new_slot = Slot(option.args[begin], option.args[end])
            end
        end
    end

    push!(direct_slots_definition, new_slot)
...
end
```

**4**

```Julia
if typeof(slot) != Expr
    ...
elseif slot.head == :vect
    new_slot = Slot(:missing, missing)

    for option in slot.args
        if typeof(option) != Expr
            setfield!(new_slot, :name, option)
        elseif option.head == :(=)
            if option.args[begin] == ...
                ...
            elseif option.args[begin] == ...
                ...
            elseif option.args[begin] == :initform
                setfield!(new_slot, :initform, option.args[end])
            else
                ...
            end
        end
    end

    push!(direct_slots_definition, new_slot)
...
end
```

#### defgeneric and defmethod

The `defgeneric` macro is pretty simple. It takes what looks like a function call and creates a generic from it.

The `defmethod` on the other hand is a bit more complicated. 
First we build the lambda list and the specializers. If a specializer is not defined we assume it is `Top`

```Julia
for lambda in method.args[begin].args[2:end]
        if typeof(lambda) == Symbol
            push!(lambda_list, lambda)
            push!(specializers, Top)
        else
            if lambda.head != :(::)
                error("Invalid syntax for method lambda_list")
            end

            push!(lambda_list, lambda.args[begin])
            push!(specializers, lambda.args[end])
        end
    end
```

Then we check if there is already a correspondant generic function defined. If not, we create a new one.

```Julia
if ! @isdefined $(method.args[begin].args[begin])
    @defgeneric $(method.args[begin].args[begin])($(lambda_list)...)
end
```

Finally we call the create_method function which takes the generic function and the method built. The function will add the new method to the list of methods of the generic function and override any if necessary

```Julia
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
```

### Juli - Notes

#### 2.15 Introspection

Implemented functions `class_name`, `class_direct_slots`, `class_slots`, `class_direct_superclasses`, `class_cpl` in `BaseStructure.jl` and added the respectively tests in `ComplexNumber.jl`. In `MultipleInheritance.jl` added tests that are in the statement of the project and also considered in class_precedence_list that `Top` is also one of the elements.

Implemented functions `generic_methods` and `method_specializers` in `GenericFunctionAndMethods.jl`. ~~THE TESTS DON'T PASS, I think the problem is in the output of the classes.~~ **Change:** Instead of appending a new method **in the end** of the list of methods of a generic functions, append it in the beginning.
