### Function to search for a target in a rotated sorted array
### This implentation makes use of mojo generics. This would work for any type that conforms to `ComparableCollectionElement`.

```python

# Search in Rotated Sorted Array

# Function to search for a target in a rotated sorted array
alias ItemType = ComparableCollectionElement


fn find[ElemType: ItemType](items: List[ElemType], target: ElemType) -> Int:
    if len(items) == 0:
        return -1

    # Initialize pointers for binary search
    left, right = 0, len(items) - 1

    # Perform binary search
    while left <= right:
        mid = (left + right) // 2  # Calculate middle index

        # If the middle element is the target, return the index
        if items[mid] == target:
            return mid

        # Determine which half is sorted
        if items[mid] >= items[left]:
            # Left half is sorted

            # Check if target lies outside the sorted left half
            if target < items[left] or target > items[mid]:
                # Target is in the right half
                left = mid + 1
            else:
                # Target is in the left half
                right = mid - 1
        else:
            # Right half is sorted

            # Check if target lies outside the sorted right half
            if target > items[right] or target < items[mid]:
                # Target is in the left half
                right = mid - 1
            else:
                # Target is in the right half
                left = mid + 1

    # Target not found
    return -1


fn main():
    # Example 1: Target exists in the array
    items = List(4, 5, 6, 7, 0, 1, 2)
    target = 0
    # Expected output: 4 (index of 0)
    # debug_assert(find(items, target) == 4, "Assertion failed")

    # Example 2: Target does not exist
    items = List(4, 5, 6, 7, 0, 1, 2)
    target = 3
    # Expected output: -1
    # debug_assert(find(items, target) == -1, "Assertion failed")

    # Example 3: Single-element array, target not present
    items = List(1)
    target = 0
    # Expected output: -1
    debug_assert(find(items, target) == -1, "Assertion failed")
```

[Source](https://github.com/ratulb/mojo_programming/blob/main/codes/search_sorted_rotated_arr.mojo)

