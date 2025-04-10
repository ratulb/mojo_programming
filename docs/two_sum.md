## Two sum

Given an array of integers nums and an integer target, return indices of the two numbers such that they add up to target.

You may assume that each input would have exactly one solution, and you may not use the same element twice.

You can return the answer in any order.

 

### Example 1:

Input: nums = [2,7,11,15], target = 9
Output: [0,1]
Explanation: Because nums[0] + nums[1] == 9, we return [0, 1].

### Example 2:

Input: nums = [3,2,4], target = 6
Output: [1,2]

### Example 3:

Input: nums = [3,3], target = 6
Output: [0,1]
 

### Constraints:

2 <= nums.length <= 104
-109 <= nums[i] <= 109
-109 <= target <= 109
Only one valid answer exists.
 
```mojo
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
```
