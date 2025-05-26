### Find First/Last
### Find first and last index of a target value in a sorted array

```python


fn find_first_last(arr: List[Int], target: Int) -> (Int, Int):
    result = (-1, -1)
    if len(arr) == 0:
        return result
    left, right = 0, len(arr) - 1

    while left <= right:
        mid = (left + right) // 2
        if arr[mid] == target:
            result[1] = mid
            left = mid + 1
        elif arr[mid] > target:
            right = mid - 1
        else:
            left = mid + 1
    left, right = (
        0,
        result[1],
    )  # result[1] -1 would keep left index at -1 for single occurence of target

    while left <= right:
        mid = (left + right) // 2
        if arr[mid] == target:
            result[0] = mid
            right = mid - 1
        elif arr[mid] > target:
            right = mid - 1
        else:
            left = mid + 1
    return result


from testing import assert_true


fn main() raises:
    arr = List(5, 7, 7, 8, 8, 10)
    target = 8
    result = find_first_last(arr, target)
    assert_true(result[0] == 3 and result[1] == 4, "Assertion failed")
    target = 6
    result = find_first_last(arr, target)
    assert_true(result[0] == -1 and result[1] == -1, "Assertion failed")

    arr = List(5, 7, 7, 8, 10)
    target = 8
    result = find_first_last(arr, target)
    assert_true(result[0] == 3 and result[1] == 3, "Assertion failed")

```


[Source](https://github.com/ratulb/mojo_programming/blob/main/codes/find_first_last.mojo)