### Largest Number
### Arrange non-negative integers to form the largest possible number and return it as a string.


fn largest_number(nums: List[Int]) raises -> String:
    if len(nums) == 0:
        return ""
    strs = List[String](capacity=len(nums))
    for each in nums:
        strs.append(String(each[]))
    sort[compare_fn](strs)
    result = StringSlice("").join(strs)
    return String(Int(result))


@parameter
fn compare_fn(left: String, right: String) -> Bool:
    return left + right > right + left


from testing import assert_true


fn main() raises:
    nums = List(10, 2)
    result = largest_number(nums)
    assert_true(result == "210", "Assertion failed")

    nums = List(3, 30, 34, 5, 9)
    result = largest_number(nums)
    assert_true(result == "9534330", "Assertion failed")

    nums = List(0, 0, 0, 0, 0)
    result = largest_number(nums)
    assert_true(result == "0", "Assertion failed")

    nums = List[Int]()
    result = largest_number(nums)
    assert_true(result == "", "Assertion failed")
