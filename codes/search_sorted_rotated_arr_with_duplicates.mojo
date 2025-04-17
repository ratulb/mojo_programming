### Search in a rotated sorted array that may contain duplicates
### Generic function to find the index of a target element in a rotated sorted list.
### Works for any type that implements ComparableCollectionElement (e.g., Int, Float, etc.).

# Define an alias for types that support comparison operations.
alias ItemType = ComparableCollectionElement


fn find[ItmType: ItemType](read items: List[ItmType], target: ItmType) -> Int:
    if len(items) == 0:
        return -1
    left, right = 0, len(items) - 1

    # Perform modified binary search to handle rotation and duplicates
    while left <= right:
        mid = left + (right - left) // 2

        # Target found at midpoint
        if items[mid] == target:
            return mid

        # Case 1: Target is less than midpoint value
        if target < items[mid]:
            # If target is greater than the left bound, it must be in the left subarray
            if target > items[left]:
                right = mid - 1
            # If target is less than the left bound, it must be in the right subarray
            elif target < items[left]:
                left = mid + 1
            # If target equals the left bound, it's a match
            else:
                return left

        # Case 2: Target is greater than midpoint value
        else:
            # If target is less than the right bound, it lies in the right subarray
            if target < items[right]:
                left = mid + 1
            # If target is greater than the right bound, it must lie to the left
            elif target > items[right]:
                right = mid - 1
            # If target equals the right bound, it's a match
            else:
                return right

    # Target not found
    return -1


from testing import assert_equal


fn main() raises:
    items = List(7, 7, 8, 9, 10, 10, 12, 1, 2, 3, 3, 4, 4, 5, 5, 6)
    targets = List(12, 7, 3, 10, 1, 6, 4)
    expected_indices = List(6, 0, 9, 5, 7, 15, 11)

    results = List[Int](capacity=len(targets))
    for i in range(len(targets)):
        index = find(items, targets[i])
        results.append(index)
    assert_equal(expected_indices, results, "Assertion failed!")

    items = List(6)
    target = 6
    index = find(items, target)
    assert_equal(index, 0, "Assertion failed")

    items = List(7, 7, 7)
    target = 7
    index = find(items, target)
    assert_equal(index, 1, "Assertion failed")

    items = List(7, 8, 4, 5)
    target = 3
    index = find(items, target)
    assert_equal(index, -1, "Assertion failed")
