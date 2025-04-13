### Given a string s, find the length of the longest substring without duplicate characters.

 
```python
from collections import Set

# Function to compute the length of the longest substring without repeating characters.
# Takes a StringLiteral `s` and returns an unsigned 16-bit integer.
fn len_longest_substr_no_char_repeats(s: StringLiteral) raises -> UInt16:
    # If the input string is empty, return 0 immediately
    if len(s) == 0:
        return 0

    # Initialize a Set to keep track of characters in the current window (substring)
    # Start by adding the first character of the string
    seen = Set(s[0])

    # `left` is the left boundary of the current sliding window (start index)
    left = 0

    # Initial max_length is 1 since we already have one character in the set
    max_length = 1

    # Start iterating from the second character to the end of the string
    for idx in range(1, len(s)):
        # If the current character is already in the set, it means a repetition
        # So we move the `left` boundary forward until we remove the duplicate
        while s[idx] in seen:
            seen.remove(s[left])
            left += 1

        # Add the current character to the set
        seen.add(s[idx])

        # Update max_length with the size of the current window (set size)
        max_length = max(max_length, len(seen))

    # Return the maximum length found
    return max_length


fn main() raises:
    s = "abcabcbb"
    print(len_longest_substr_no_char_repeats(s))  # 3
    s = "bbbbb"
    print(len_longest_substr_no_char_repeats(s))  # 1
    s = "pwwkew"
    print(len_longest_substr_no_char_repeats(s))  # 3

```


[Source](https://github.com/ratulb/mojo_programming/blob/main/codes/longest_substr_no_char_repeats.mojo)
