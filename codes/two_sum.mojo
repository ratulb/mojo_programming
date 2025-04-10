from collections import Dict


fn two_sum(nums: List[Int], target: Int) -> Tuple[Int, Int]:
    indices = (-1, -1)
    if len(nums) <= 1:
        return indices
    var value_indices = Dict[Int, Int]()  # value -> index of value
    for idx in range(len(nums)):
        diff = target - nums[idx]
        if diff in value_indices:
            indices[0] = value_indices.get(diff).value()
            indices[1] = idx
        else:
            value_indices[nums[idx]] = idx
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
