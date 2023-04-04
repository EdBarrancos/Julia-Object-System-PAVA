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
- [ ] Which types do we need to support with the built in types? For example, do we need to support Unsigned ints?

### Current State

- [x] x Tests
- [ ] 2.0 Macros
  - [ ] 2.0.1 defclass
  - [ ] 2.0.2 defgeneric
  - [ ] 2.0.3 defmethpd
- [x] 2.1 Classes
- [x] 2.2 Instances
- [x] 2.3 Slot Access
- [x] 2.4 Generic Functions and methods
- [x] 2.5 Pre-defined Generic Functions and Methods
- [ ] 2.6 MetaObjects - **Liliana**
- [ ] 2.7 Class Options - **Edu**
- [ ] 2.8 Readers and Writers - **Liliana**
- [x] 2.9 Generic Function Calls
- [x] 2.10 Multiple Dispatch
- [ ] 2.11 Multiple Inheritance
- [x] 2.12 Class Hierarchy
- [ ] 2.13 Class Precedence List - **Miguel**
- [x] 2.14 Built-In Classes
- [ ] 2.15 Introspection - **Juliana**
- [ ] 2.16 Meta-Object Protocols
- [ ] 2.16.1 Class Instantiation Protocol
- [ ] 2.16.2 The Compute Slots Protocol
- [ ] 2.16.3 Slot Access Protocol
- [ ] 2.16.4 Class Precedence List protocol
- [ ] 2.17 Multiple Meta-Class Inheritance
- [ ] 2.18 *Extensions*
- [ ] 2.18.1 Meta-Objects for slot definitions
- [ ] 2.18.2 CLOS-like method combination for generic functions
- [ ] 2.18.3 CLOS or Dylan's strategy for computing the class precedence list
- [ ] 2.18.4 Additional Metaobject protocols

### Edu - Notes

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

### Juli - Notes

#### 2.15 Introspection

Implemented functions `class_name`, `class_direct_slots`, `class_slots`, `class_direct_superclasses`, `class_cpl` in `BaseStructure.jl` and added the respectively tests in `ComplexNumber.jl`. In `MultipleInheritance.jl` added tests that are in the statement of the project and also considered in class_precedence_list that `Top` is also one of the elements.