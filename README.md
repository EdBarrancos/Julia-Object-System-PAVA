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

### Current State

- [ ] 2.0 Macros (defclass, defgeneric, defmethod)
- [x] 2.1 Classes
- [x] 2.2 Instances
- [x] 2.3 Slot Access - **Juliana**
- [x] 2.4 Generic Functions and methods
- [ ] 2.5 Pre-defined Generic Functions and Methods - **Miguel**
- [ ] 2.6 MetaObjects - **Liliana**
- [ ] 2.7 Class Options
- [ ] 2.8 Readers and Writers - **Liliana**
- [x] 2.9 Generic Function Calls
- [ ] 2.10 Multiple Dispatch - **Test/Edu**
- [ ] 2.11 Multiple Inheritance
- [x] 2.12 Class Hierarchy
- [ ] 2.13 Class Precedence List - **Miguel**
- [ ] 2.14 Built-In Classes - **Edu**
- [ ] 2.15 Introspection - **Juliana**
- [ ] 2.16 meta-Object Protocols
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
- [ ] When the called function does not have any applicable method to the arguments given. Currently Im just throwing an error, but we need to call the generic function *non_applicable_method*. **Addressed in: 2.9 Generic Function Calls**
  - Kind of done. But throws an error, because we need built in types first, because it receives a Tuple of Arguments as an argument

##### Issues

As of right now, the method `is_method_applicable` will not work with native types. Im not sure if this will be fixed when we implement the `Built-in-types`, if not, this functions will need some modifications.

#### 2.9 - Generic Function Calls

Quick sum up. To call a generic function, we compute the effective method list (Done in the 2.4). Then we need to apply the first method. To apply a method, we need to first bind the arguments to variable names, next we need to bind the `call_next_method` function and finally run the methods body.

##### Concerns

The binding of arguments currently is super ugly. But I'm not sure how to improve it.

Not sure if the binding of `call_next_method` is correct.

##### Extra TODOs

- [x] Make a function to verify if the argument is of the correct type or throw error
- [x] Make access methods
- [x] Test `call_next_method`
- [ ] Make a test module
