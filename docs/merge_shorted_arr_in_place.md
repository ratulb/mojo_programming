### Merge nums2 into nums1 (in-place)
### Given two sorted arrays nums1 (size m + n, with m valid elements followed by n zeros) and nums2 (size n), merge them in-place into nums1 as one sorted array.

```python

fn merge(mut nums1: List[Int], nums2: List[Int]):
    if len(nums1) == 0 or len(nums2) == 0:
        return
    # Set pointer m to the last valid element in nums1 (i.e., excluding trailing zeros)
    m = len(nums1) - len(nums2) - 1

    # Set pointer n to the last element of nums2
    n = len(nums2) - 1

    # Set pointer last to the end of nums1 (i.e., last index where final element will go)
    last = len(nums1) - 1

    # Traverse both arrays from the end and fill nums1 from the back
    while m >= 0 and n >= 0:
        if nums1[m] >= nums2[n]:
            # If current nums1 element is greater, place it at 'last' and move pointers
            nums1[last] = nums1[m]
            m -= 1
        else:
            # Else, place nums2[n] at 'last' and move pointers
            nums1[last] = nums2[n]
            n -= 1
        last -= 1

    # If there are leftover elements in nums2 (i.e., nums2 had smaller elements)
    while n >= 0:
        nums1[last] = nums2[n]
        last -= 1
        n -= 1

    # No need to handle leftover nums1 elements, they are already in place 1

from testing import assert_equal


fn main() raises:
    nums1 = List[Int](5, 8, 11, 13, 0, 0, 0)
    nums2 = List[Int](3, 9, 19)
    merge(nums1, nums2)
    assert_equal(nums1, List(3, 5, 8, 9, 11, 13, 19), "Assertion failed")
    nums1 = List(1, 2, 3, 0, 0, 0)
    nums2 = List(2, 5, 6)
    merge(nums1, nums2)
    assert_equal(nums1, List(1, 2, 2, 3, 5, 6), "Assertion failed")

    nums1 = List(1)
    nums2 = List[Int]()
    merge(nums1, nums2)
    assert_equal(nums1, List(1), "Assertion failed")

```

[Source](https://github.com/ratulb/mojo_programming/blob/main/codes/merge_shorted_arr_in_place.mojo)
