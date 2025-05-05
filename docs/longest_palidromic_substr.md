### Longest Palindromic Substring
### Given a string s, return the longest palindromic substring therein

```python


fn longest_palindrome(s: String) -> String:
    if len(s) == 0:
        return s
    longest = String("")
    for i in range(len(s)):
        left, right = i, i
        find_longest(left, right, s, longest)
        left, right = i, i + 1
        find_longest(left, right, s, longest)
    return longest


fn find_longest(mut left: Int, mut right: Int, s: String, mut longest: String):
    while 0 <= left and right < len(s) and s[left] == s[right]:
        if right - left + 1 > len(longest):
            longest = s[left : right + 1]
        left -= 1
        right += 1


from testing import assert_true


fn main() raises:
    var s: String = "babad"
    var expected: String = "bab"
    result = longest_palindrome(s)
    assert_true(result == expected, "Assertion failed")

    s = "cbbd"
    expected = "bb"
    result = longest_palindrome(s)
    assert_true(result == expected, "Assertion failed")

    s = "racecar"
    expected = "racecar"
    result = longest_palindrome(s)
    assert_true(result == expected, "Assertion failed")

```


[Source](https://github.com/ratulb/mojo_programming/blob/main/codes/longest_palidromic_substr.mojo)