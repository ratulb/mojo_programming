### Given an array of line heights, find the two lines that form the container holding the most water.

```python

fn max_area(heights: List[Int]) -> Int:
    # If there are fewer than 2 lines, no container can be formed
    if len(heights) < 2:
        return 0

    left, right = 0, len(heights) - 1

    max_area = 0

    while left < right:
        # Height of container is limited by the shorter of the two lines
        min_height = min(heights[left], heights[right])

        # Calculate area formed between the two lines and update max_area if it's larger
        max_area = max(max_area, (right - left) * min_height)

        # Move the pointer that's at the shorter line inward to potentially find a taller line
        # This can potentially increase the area despite reducing the width
        if heights[left] <= heights[right]:
            left += 1
        else:
            right -= 1

    return max_area


from testing import assert_equal


fn main():
    heights = List(1, 8, 6, 2, 5, 4, 8, 3, 7)
    mx_area = max_area(heights)
    assert_equal(mx_area, 49, "Assertion failed")

    heights = List(1, 1)
    mx_area = max_area(heights)
    assert_equal(mx_area, 1, "Assertion failed")

```
[Source code](https://github.com/ratulb/mojo_programming/blob/main/codes/water_container_max_area.mojo)

