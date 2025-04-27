### Count 1s For Each Entry
### Return an array where each element at index i (0 ≤ i ≤ n) is the number of 1's in the binary representation of i.

```python


fn count_bits(n: Int) -> List[Int]:
    result = List(length=n + 1, fill=0)
    power = 1
    for i in range(1, n + 1):
        if i == power * 2:
            power = i
        result[i] = 1 + result[i - power]

    return result


from testing import assert_equal


fn main() raises:
    n = 2
    result = count_bits(n)
    assert_equal(List(0, 1, 1), result, "Assertion failed")

    n = 5
    result = count_bits(n)
    assert_equal(List(0, 1, 1, 2, 1, 2), result, "Assertion failed")

```


[Source](https://github.com/ratulb/mojo_programming/blob/main/codes/count_bits.mojo)

[Rust solution](https://ratulb.github.io/programming_problems_and_datastructures_in_rust/count_bits/introduction.html)
