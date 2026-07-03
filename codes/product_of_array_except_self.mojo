"""
Product of Array Except Self
Given an integer array `nums`, return a new array where `result[i]` is the product
of all elements of `nums` *except* `nums[i]`.

You must do this **without division** and in O(n) time.

**Approach: Prefix & Suffix Products**

The product at index `i` = (product of everything left of `i`) × (product of everything right of `i`).

We compute this in two passes with O(1) extra space (excluding the output array):

1. **Left pass:** iterate forward, store the running prefix product at each position.
2. **Right pass:** iterate backward, multiply each position by the running suffix product.

Each pass is O(n), so total time is O(n). Only a few integer variables are used
beyond the output array, so space is O(1) auxiliary.
"""


def product_except_self(nums: List[Int]) -> List[Int]:
    # If the input list is empty, return it as is
    if len(nums) == 0:
        return nums.copy()

    # Store the length of the input list
    var length = len(nums)

    # Initialize the result list with all 1s. This will store our final answer.
    result = [1] * length

    # prefix_product holds the product of all elements to the *left* of the current index
    prefix_product = 1
    for idx in range(length):
        # For each index, store the current prefix product
        result[idx] = prefix_product
        # Update the prefix product by multiplying it with the current number
        prefix_product *= nums[idx]

    # suffix_product holds the product of all elements to the *right* of the current index
    suffix_product = 1
    # Iterate from right to left
    for idx in range(length - 1, -1, -1):
        # Multiply the result at index with the current suffix product
        result[idx] *= suffix_product
        # Update the suffix product by multiplying with current number
        suffix_product *= nums[idx]

    return result^


# Entry point
def main():
    # Example input
    nums = [1, 2, 3, 4]
    # Call the function to get result
    result = product_except_self(nums)  # Output should be [24, 12, 8, 6]
    # Print the result
    print(result)
