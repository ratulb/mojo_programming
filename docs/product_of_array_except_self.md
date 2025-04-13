### Function to compute the product of all elements in the list except the one at each index

```python
fn product_except_self(nums: List[Int]) -> List[Int]:
    # If the input list is empty, return it as is
    if len(nums) == 0:
        return nums

    # Store the length of the input list
    len = len(nums)

    # Initialize the result list with all 1s. This will store our final answer.
    result = List(1) * len

    # prefix_product holds the product of all elements to the *left* of the current index
    prefix_product = 1
    for idx in range(len):
        # For each index, store the current prefix product
        result[idx] = prefix_product
        # Update the prefix product by multiplying it with the current number
        prefix_product *= nums[idx]

    # suffix_product holds the product of all elements to the *right* of the current index
    suffix_product = 1
    # Iterate from right to left
    for idx in range(len - 1, -1, -1):
        # Multiply the result at index with the current suffix product
        result[idx] *= suffix_product
        # Update the suffix product by multiplying with current number
        suffix_product *= nums[idx]

    return result


# Entry point
fn main():
    # Example input
    nums = List(1, 2, 3, 4)
    # Call the function to get result
    result = product_except_self(nums)  # Output should be [24, 12, 8, 6]
    # Print the result
    print(result.__str__())
```
