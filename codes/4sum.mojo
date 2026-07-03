"""
4SUM
Given an integer array `nums` and a target value `target`, return all unique quadruplets
`(a, b, c, d)` such that `a + b + c + d == target` and all indices are distinct.

**Approach: Sort + Nested Two Pointers**

Extends the 3SUM O(n²) approach by adding one more outer loop:

1. Sort the array.
2. Fix `i`, then fix `j` (> i). For each pair, use two pointers (`low`, `high`) on the remaining subarray.
3. If the four sum to `target` — record the quadruplet, move both pointers, and skip duplicates.
4. If the sum is too low, advance `low`; if too high, retreat `high`.
5. Skip duplicate values at both the outer loops and the pointer level to avoid repeated results.

This runs in O(n³) time and O(log n) space (for sorting).
"""

comptime Quadruplet = Tuple[Int, Int, Int, Int]


# Function to find all unique quadruplets that sum up to target
def quadruplets(mut nums: List[Int], target: Int) -> List[Quadruplet]:
    var result: List[Quadruplet] = []
    if len(nums) == 0:
        return result^
    var length = len(nums)
    sort(nums)
    for i in range(length - 3):
        if i > 0 and nums[i] == nums[i - 1]:
            continue
        for j in range(i + 1, length - 2):
            if j > i + 1 and nums[j - 1] == nums[j]:
                continue
            var low, high = j + 1, length - 1
            while low < high:
                four_sum = nums[i] + nums[j] + nums[low] + nums[high]
                if four_sum == target:
                    result.append(
                        Quadruplet(nums[i], nums[j], nums[low], nums[high])
                    )
                    low += 1
                    high -= 1
                    while low < high and nums[low] == nums[low - 1]:
                        low += 1
                    while low < high and nums[high] == nums[high + 1]:
                        high -= 1
                elif four_sum < target:
                    low += 1
                else:
                    high -= 1
    return result^


def main():
    var nums = [1, 0, -1, 0, -2, 2]
    var target = 0
    var result = quadruplets(nums, target)
    for each in result:
        print(each[0], each[1], each[2], each[3])
