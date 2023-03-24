# Julia-Object-System

## Description

JOS (Julia Object System) is an extension to the Julia Programming language that supports classes and metaclasses, multiple inheritance and generic functions with multiple-dispatch methods.

The implementation should follow the way those ideas were implemented in CLOS, in particular, in what regards the CLOS MOP.

## Info

This project was made for the course "Advanced Programming" by:

- Eduardo Barrancos
- Juliana Yang
- Liliana Zheng

## Development

### Edu - Notes

#### ClassStructure - 24-03

I defined a `BaseStructure` struct. The idea is that everything is an instance of `BaseStructure`

It has two fields. One for a reference to another `BaseStructure` which represents the connection of `class_of`. And another for slots, mapping a symbol to a value. This will vary depending on what we are creating.

Then I defined, Top, Object and Class (Base Metaclass) and created the circular relations between those.

In the next step I will try to create, by hand (without a macro), the ComplexNumber class

Possible TODOs:

- [ ] Function to compute class_precedence_list
- [ ] Way to get slots (slots = direct_slots + superclasses.slots)
  - [ ] Verify conflicts
- [ ] Slot access (get_property)
- [ ] class_of
- [ ] Class Options
  - [ ] Define Metaclass
  - [ ] set reader
  - [ ] set writer
  - [ ] set init_form
- [ ] print object (needs generic function and methods)
- [ ] auto generate getters and setters
- [ ] Multiple inheritance
- [ ] Built in classes
- [ ] Introspection
  - [ ] class_name
  - [ ] class_direct_slots
  - [ ] class_slots
  - [ ] class_direct_superclasses
  - [ ] class_cpl (class_precedence_list)
- [ ] new(...)
- [ ] Multiple metaclass inheritance
