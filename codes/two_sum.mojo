# Two Sum Problem:
# Given an array of integers `nums` and a target value `target`,
# return the indices of two numbers such that they add up to `target`.

from collections import Dict

fn two_sum(nums: List[Int], target: Int) -> Tuple[Int, Int]:
    # Default return value: (-1, -1) if no valid pair is found
    indices = (-1, -1)

    # Early exit: If list has 0 or 1 elements, no pair can be formed
    if len(nums) <= 1:
        return indices

    # Create a dictionary to map each value to its index for quick lookup
    # Format: value_indices[value] = index
    var value_indices = Dict[Int, Int]()  # value -> index

    # Iterate through the array
    for idx in range(len(nums)):
        # Calculate the number needed to reach the target
        diff = target - nums[idx]

        # If this difference was seen before, we found the pair
        if diff in value_indices:
            # Retrieve the stored index of the matching number
            indices[0] = value_indices.get(diff).value()
            # Store the current index as the second of the pair
            indices[1] = idx
        else:
            # Store the current number and its index for future reference
            value_indices[nums[idx]] = idx

    # Return the result tuple
    return indices

fn two_sum_costly(nums: List[Int], target: Int) -> Tuple[Int, Int]:
    if len(nums) <= 1:
        return (-1, -1)
    for i in range(len(nums)):
        for j in range(i + 1, len(nums)):
            if nums[i] + nums[j] == target:
                return (i, j)
    return (-1, -1)


fn main():
    nums = List(2, 7, 11, 15)
    target = 9
    indices = two_sum(nums, target)
    debug_assert(indices[0] == 0 and indices[1] == 1, "Assertion failed")
    target = 18
    indices = two_sum(nums, target)
    debug_assert(indices[0] == 1 and indices[1] == 2, "Assertion failed")
    target = 100
    indices = two_sum(nums, target)
    debug_assert(indices[0] == -1 and indices[1] == -2, "Assertion failed")
