### Given an array nums, return all unique quadruplets [a, b, c, d] such that a + b + c + d == target and all indices are distinct.

```python

from collections import InlineArray

alias Quadruplet = InlineArray[Int, 4]

# Function to find all unique triplets that sum up to target
fn quadruplets(mut nums: List[Int], target: Int) -> List[Quadruplet]:
    result = List[Quadruplet]()
    if len(nums) == 0:
        return result
    length = len(nums)
    sort(nums)
    for i in range(length - 3):
        if i > 0 and nums[i] == nums[i - 1]:
            continue
        for j in range(i + 1, length - 2):
            if j > i + 1 and nums[j - 1] == nums[j]:
                continue
            low, high = j + 1, length - 1
            while low < high:
                four_sum = nums[i] + nums[j] + nums[low] + nums[high]
                if four_sum == target:
                    result.append(
                        Quadruplet(nums[i], nums[j], nums[low], nums[high])
                    )
                    low += 1
                    high -= 1
                    while low < high and nums[low] == nums[low -1]:
                        low += 1
                    while low < high and nums[high] == nums[high + 1]:
                        high -= 1
                elif four_sum < target:
                    low += 1
                else:
                    high -= 1
    return result


fn main():
    nums = List(1, 0, -1, 0, -2, 2)
    target = 0
    result = quadruplets(nums, target)
    for each in result:
        print(each[][0], each[][1], each[][2], each[][3])

```

[Source](https://github.com/ratulb/mojo_programming/blob/main/codes/4sum.mojo)

