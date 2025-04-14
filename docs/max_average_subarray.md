### Find the maximum average of any contiguous subarray of length k from the array.

```python
fn find_max_average(read nums: List[Int], window_size: UInt) -> Float16:
    length = len(nums)
    if length == 0 or window_size == 0:
        return 0.0  # Return 0 if input is invalid

    var max_average: Float16 = 0.0
    window_sum = 0

    # Compute sum of the first 'window_size' elements
    for idx in range(window_size):
        window_sum += nums[idx]
    max_average = Float16(window_sum / window_size)  # Initialize max average

    # Slide the window over the array
    for idx in range(window_size, length):
        window_sum += nums[idx]                     # Add next element
        window_sum -= nums[idx - window_size]       # Remove the element going out of window
        average = Float16(window_sum / window_size) # Current window average
        max_average = max(max_average, average)     # Update max average if needed

    return max_average


fn main():
    nums = List(1, 12, -5, -6, 50, 3)
    window_size = 4
    max_average = find_max_average(nums, window_size)
    debug_assert(max_average == 12.75, "Assertion failed")  # Test case check
```


[Source](https://github.com/ratulb/mojo_programming/blob/main/codes/max_average_subarray.mojo)
