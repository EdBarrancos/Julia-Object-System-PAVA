# @defgeneric add(a, b)
add = new_generic_function(:add, [:a, :b])

#= @defmethod add(a::ComplexNumber, b::ComplexNumber) =
  new(ComplexNumber, real=(a.real + b.real), imag=(a.imag + b.imag)) =#

add = new_method(
    add, 
    :add, 
    [:a, :b], 
    [ComplexNumber, ComplexNumber], 
    function (call_next_method, a, b)
        BaseStructure(
            ComplexNumber,
            Dict(
                :real=>a.real + b.real,
                :imag=>a.imag + b.imag
            )
        )
    end
)