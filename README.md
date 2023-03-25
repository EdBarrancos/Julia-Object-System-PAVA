# Julia-Object-System

## Description

JOS (Julia Object System) is an extension to the Julia Programming language that supports classes and metaclasses, multiple inheritance and generic functions with multiple-dispatch methods.

The implementation should follow the way those ideas were implemented in CLOS, in particular, in what regards the CLOS MOP.

## Info

This project was made for the course "Advanced Programming" by:

- Eduardo Barrancos
- Juliana Yang
- Liliana Zheng
- Miguel Faria

## Development

### Doubts

- What should be the result of `class_of(class_of(draw))`?
- Check if `class_of` is correctly implemented

### Current State

- [x] 2.1
- [x] 2.2
- [ ] 2.3 - Juliana
- [ ] 2.4 - Edu
- [ ] 2.5 - Miguel
- [ ] 2.6 - Liliana
- [ ] 2.7
- [ ] 2.8
- [ ] 2.9
- [ ] 2.10
- [ ] 2.11
- [ ] 2.12
- [ ] 2.13
- [ ] 2.14
- [ ] 2.15
- [ ] 2.16
- [ ] 2.16.1
- [ ] 2.16.2
- [ ] 2.16.3
- [ ] 2.16.4
- [ ] 2.17
- [ ] 2.18

### Edu - Notes

#### ClassStructure - 24-03

I defined a `BaseStructure` struct. The idea is that everything is an instance of `BaseStructure`

It has two fields. One for a reference to another `BaseStructure` which represents the connection of `class_of`. And another for slots, mapping a symbol to a value. This will vary depending on what we are creating.

Then I defined, Top, Object and Class (Base Metaclass) and created the circular relations between those.

In the next step I will try to create, by hand (without a macro), the ComplexNumber class
