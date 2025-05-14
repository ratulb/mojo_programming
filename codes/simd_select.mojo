### SIMD Select
### Select based on a SIMD (Single Instruction, Multiple Data) mask
### This example demonstrates how to use SIMD.select() to perform element-wise conditional selection between two SIMD vectors based on a boolean mask.


from testing import assert_true


fn main() raises:
    # Create a SIMD (Single Instruction, Multiple Data) boolean selector vector of size 4.
    # Each element is a boolean value (True or False), indicating which value to select from `left` or `right`.
    # - If selector[i] == True, take the value from `left[i]`
    # - If selector[i] == False, take the value from `right[i]`
    selector = SIMD[DType.bool, 4](False, True, False, True)

    # Define a SIMD vector `left` with 4 elements of unsigned 8-bit integers
    left = SIMD[DType.uint8, 4](0, 42, 0, 42)

    # Define another SIMD vector `right` with 4 elements of unsigned 8-bit integers
    right = SIMD[DType.uint8, 4](42, 0, 42, 0)

    # Use the selector to choose elements from either `left` or `right`:
    # result[i] = left[i] if selector[i] else right[i]
    result = selector.select(left, right)
    #   → result = [42, 42, 42, 42]

    expected = SIMD[DType.uint8, 4](42)  #   → expected = [42, 42, 42, 42]
    assert_true(all(result == expected))
