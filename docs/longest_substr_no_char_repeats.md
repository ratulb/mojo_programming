### Given a string s, find the length of the longest substring without duplicate characters.

 
```python
fn len_longest_substr_no_char_repeats(s: StringLiteral) raises -> UInt16:
    if len(s) == 0:
        return 0
    seen = Set(s[0])
    left = 0
    max_length = 1
    for idx in range(1, len(s)):
        while s[idx] in seen:
            seen.remove(s[left])
            left += 1
        seen.add(s[idx])
        max_length = max(max_length, len(seen))
    return max_length


fn main() raises:
    s = "abcabcbb"
    print(len_longest_substr_no_char_repeats(s))
    s = "bbbbb"
    print(len_longest_substr_no_char_repeats(s))
    s = "pwwkew"
    print(len_longest_substr_no_char_repeats(s))
```



[Source](https://github.com/ratulb/mojo_programming/blob/main/codes/len_longest_substr_no_char_repeats.mojo)
