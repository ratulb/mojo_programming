### Merge Itervals
### Merge overlapping intervals

```python


@parameter
fn compare_fn(interval1: (Int, Int), interval2: (Int, Int)) -> Bool:
    return interval1[0] < interval2[0]


fn merge_intervals(mut intervals: List[(Int, Int)]) -> List[(Int, Int)]:
    if len(intervals) == 0:
        return List[(Int, Int)]()

    sort[compare_fn](intervals)

    result = List[(Int, Int)]()
    result.append(intervals[0])
    for curr_interval in intervals[1:]:
        start, end = curr_interval[]
        last_interval = result[-1]
        last_start, last_end = last_interval
        if start <= last_end:
            result[len(result) - 1] = (last_start, max(last_end, end))
        else:
            result.append(curr_interval[])

    return result


from testing import assert_true


fn main() raises:
    intervals = List[(Int, Int)]((1, 3), (2, 6), (8, 10), (15, 18))
    expected = List[(Int, Int)]((1, 6), (8, 10), (15, 18))
    result = merge_intervals(intervals)
    i = 0
    for each in result:
        assert_true(
            each[][0] == expected[i][0] and each[][1] == expected[i][1],
            "Assertion failed",
        )
        i += 1

    intervals = List[(Int, Int)]((1, 4), (4, 5))
    expected = List[(Int, Int)]((1, 5))
    result = merge_intervals(intervals)
    i = 0
    for each in result:
        assert_true(
            each[][0] == expected[i][0] and each[][1] == expected[i][1],
            "Assertion failed",
        )
        i += 1

```


[Source](https://github.com/ratulb/mojo_programming/blob/main/codes/merge_intervals.mojo)