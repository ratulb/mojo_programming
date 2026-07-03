"""
Maximum Subarray Sum (Kadane's Algorithm)
Given an integer array `nums`, find the contiguous subarray (containing at least one element)
with the largest sum, and return that sum.

**Approach: Kadane's Algorithm (Dynamic Programming)**

A brute-force O(n²) check of every subarray is unnecessarily slow. Kadane's algorithm
solves it in a single pass:

1. Maintain `running_sum` — the best sum ending at the current position.
2. At each step, decide: extend the existing subarray or start fresh from `nums[i]`.
   This is `running_sum = max(running_sum + nums[i], nums[i])`.
3. Keep `max_sum` = the largest `running_sum` seen so far.

The key insight: if `running_sum` ever drops below the current element alone,
it's better to start a new subarray from here. This works because a subarray
must be contiguous — you cannot skip elements.

This runs in O(n) time and O(1) space.
"""


# Function to find the subarray with the maximum sum
def max_sum_sub_array(nums: List[Int]) -> Int:
    # If the list is empty, return 0 as no subarray exists
    if len(nums) == 0:
        return 0

    # Initialize the running sum and max sum with the first element
    # running_sum: current subarray sum being tracked
    # max_sum: maximum subarray sum seen so far
    var running_sum, max_sum = nums[0], nums[0]

    # Iterate over the list starting from the second element
    for idx in range(1, len(nums)):
        # Decide whether to extend the previous subarray or start a new subarray at current index
        running_sum = max(running_sum + nums[idx], nums[idx])

        # Update max_sum if the current running_sum is greater
        max_sum = max(max_sum, running_sum)

    # Return the maximum subarray sum found
    return max_sum


def main():
    nums = [-2, 1, -3, 4, -1, 2, 1, -5, 4]
    max_sum = max_sum_sub_array(nums)
    debug_assert(max_sum == 6, "Assertion failed")
    nums = [5, 4, -1, 7, 8]
    max_sum = max_sum_sub_array(nums)
    debug_assert(max_sum == 23, "Assertion failed")
