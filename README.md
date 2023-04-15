# Julia-Object-System

## Description

JOS (Julia Object System) is an extension to the Julia Programming language that supports classes and metaclasses, multiple inheritance and generic functions with multiple-dispatch methods.

The implementation should follow the way those ideas were implemented in CLOS, in particular, in what regards the CLOS MOP.

## Info

This project was made for the course "Advanced Programming" by:

- Eduardo Barrancos 95566
- Juliana Yang 95617
- Xin Zheng 97073
- Miguel Faria 105704

### How to run tests

- Simple run the file `runtests.jl`
- Or run it on the terminal
  - type `julia` then `]`
  - Something like `(JuliaObjectSystem) pkg>` should be appearing on your terminal
  - Then type `test`
  - If this not work, try this:
    - `activate .`
    - **Try Again or:**
    - `add Test`
    - **Try Again or:**
    - `test JuliaObjectSystem`