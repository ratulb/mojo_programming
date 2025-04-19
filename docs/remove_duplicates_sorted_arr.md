### Remove duplicates from sorted array
### This implementation mutates the array in place.
### Post de-duplication, only the unique elements are retained.
### After the last unique element, all entries which have been shifted are discarded.

```python

fn remove_duplicates(mut nums: List[Int]) -> None:
    # If the list has 0 or 1 element, it's already unique
    if len(nums) < 2:
        return

    # `left` points to the position where the next unique element should go
    left = 0

    # Start from second element and iterate through the list
    for right in range(1, len(nums)):
        # If a unique value is found (not equal to the previous one),
        # move it to the `left + 1` position
        if nums[right - 1] != nums[right]:
            left += 1
            nums[left] = nums[right]

    # After all unique elements are placed at the beginning of the list,
    # remove all remaining elements beyond the `left` index
    for _ in range(len(nums) - 1, left, -1):
        _ = nums.pop()  # Discard redundant elements


# Import testing helper for assertions
from testing import assert_equal


fn main() raises:
    # Each test validates that the function keeps only unique sorted elements
    nums = List(1, 1)
    remove_duplicates(nums)
    assert_equal(nums, List(1), "Assertion failed")

    nums = List(1, 1, 1)
    remove_duplicates(nums)
    assert_equal(nums, List(1), "Assertion failed")

    nums = List(1, 1, 1, 2)
    remove_duplicates(nums)
    assert_equal(nums, List(1, 2), "Assertion failed")

    nums = List(1, 1, 1, 2, 3, 3, 3, 5, 5, 6, 6, 8, 8, 8, 9, 10, 10)
    remove_duplicates(nums)
    assert_equal(nums, List(1, 2, 3, 5, 6, 8, 9, 10), "Assertion failed")

    nums = List(1, 1, 1, 2, 3, 3, 3, 5, 5, 6, 6, 8, 8, 8, 9, 10, 10, 11)
    remove_duplicates(nums)
    assert_equal(nums, List(1, 2, 3, 5, 6, 8, 9, 10, 11), "Assertion failed")


```

[Source code](https://github.com/ratulb/mojo_programming/blob/main/codes/remove_duplicates_sorted_arr.md)

