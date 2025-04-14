# Given an integer array nums, find the subarray with the largest sum, and return its sum.


# Function to find the subarray with the maximum sum
fn max_sum_sub_array(nums: List[Int]) -> Int:
    # If the list is empty, return 0 as no subarray exists
    if len(nums) == 0:
        return 0

    # Initialize the running sum and max sum with the first element
    # running_sum: current subarray sum being tracked
    # max_sum: maximum subarray sum seen so far
    running_sum, max_sum = nums[0], nums[0]

    # Iterate over the list starting from the second element
    for idx in range(1, len(nums)):
        # Decide whether to extend the previous subarray or start a new subarray at current index
        running_sum = max(running_sum + nums[idx], nums[idx])

        # Update max_sum if the current running_sum is greater
        max_sum = max(max_sum, running_sum)

    # Return the maximum subarray sum found
    return max_sum


def main():
    nums = List(-2, 1, -3, 4, -1, 2, 1, -5, 4)
    max_sum = max_sum_sub_array(nums)
    debug_assert(max_sum == 6, "Assertion failed")
    nums = List(5,4,-1,7,8)
    max_sum = max_sum_sub_array(nums)
    debug_assert(max_sum == 23, "Assertion failed")
