# Given a sorted, rotated array `nums`, find and return the minimum element.
# The solution uses binary search to achieve O(log n) time complexity.

fn find_min(nums: List[Int]) -> Int:
    # Handle edge case: empty list
    if len(nums) == 0:
        return Int.MIN  # Return the minimum representable integer

    # Handle edge case: single-element list
    elif len(nums) == 1:
        return nums[0]

    else:
        # Initialize binary search pointers
        left, right = 0, len(nums) - 1
        curr_min = nums[0]  # Assume first element is the minimum initially

        while left <= right:
            # If the current window is sorted, the smallest element is at the left
            if nums[left] <= nums[right]:
                return min(curr_min, nums[left])

            # Compute the mid index
            mid = (left + right) // 2

            # Update the minimum seen so far
            cur_min = min(curr_min, nums[mid])

            # Determine which side is unsorted (contains the pivot)
            if nums[mid] >= nums[left]:
                # Left half is sorted, so min must be in the right half
                left = mid + 1
            else:
                # Right half is sorted, so min must be in the left half (including mid)
                right = mid - 1

        # Fallback return — should never be reached in a rotated sorted array
        return curr_min  # Keeps compiler happy

fn main():
    nums = List[Int]()
    minimum = find_min(nums)
    debug_assert(minimum == Int.MIN, "Assertion failed")
    nums = List(4, 5, 6, 7, 0, 1, 2)
    minimum = find_min(nums)
    debug_assert(minimum == 0, "Assertion failed")
    nums = List(4)
    minimum = find_min(nums)
    debug_assert(minimum == 4, "Assertion failed")
    nums = List(4, 5)
    minimum = find_min(nums)
    debug_assert(minimum == 4, "Assertion failed")
    nums = List(5, 4)
    minimum = find_min(nums)
    debug_assert(minimum == 4, "Assertion failed")
    nums = List(3, 4, 5, 1, 2)
    minimum = find_min(nums)
    debug_assert(minimum == 1, "Assertion failed")
    nums = List(11, 13, 15, 17)
    minimum = find_min(nums)
    debug_assert(minimum == 11, "Assertion failed")
    nums = List(11, 13, 15, 17, 1, 1, 2, 2)
    minimum = find_min(nums)
    debug_assert(minimum == 1, "Assertion failed")
