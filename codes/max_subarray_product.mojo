# Function to find the maximum product of a contiguous subarray
fn max_subarray_product(read nums: List[Int]) -> Int:
    # Handle edge case: empty array
    if len(nums) == 0:
        return 0
    # Handle edge case: single element
    elif len(nums) == 1:
        return nums[0]
    else:
        # Initialize max_product: if first element is 0, set to 1 temporarily
        max_product = 1 if nums[0] == 0 else nums[0]
        # Track both current max and min products (important for handling negatives)
        curr_max, curr_min = 1, 1

        # Iterate through all elements
        for idx in range(0, len(nums)):
            num = nums[idx]

            # Reset both max and min when zero is encountered (new subarray starts)
            if num == 0:
                curr_max, curr_min = 1, 1
                continue

            # Preserve previous curr_max for updating curr_min
            curr_max_copy = curr_max

            # Update current max and min by considering:
            # - current number alone
            # - product of current number with previous max
            # - product of current number with previous min (for negatives)
            curr_max = max(curr_max * num, curr_min * num, num)
            curr_min = min(curr_max_copy * num, curr_min * num, num)

            # Update the global max product
            max_product = max(max_product, curr_max)

        return max_product


# Entry point
fn main():
    nums = List(2, 3, -2, 4)  # Expected maximum product subarray: [2, 3] => 6
    max_product = max_subarray_product(nums)
    print(max_product)
    debug_assert(max_product == 6, "Assertion failed")
