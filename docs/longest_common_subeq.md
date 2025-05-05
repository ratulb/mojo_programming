### Longest Common Subsequence Recursive
### Return the length of the longest common subsequence between two strings, or 0 if none exists

```python


fn longest_subseq(mut text1: String, mut text2: String) raises -> Int:
    if len(text1) == 0 or len(text2) == 0:
        return 0
    if text1[len(text1) - 1] == text2[len(text2) - 1]:
        text1 = text1[0:-1]
        text2 = text2[0:-1]
        return 1 + longest_subseq(text1, text2)
    else:
        text_1 = text1[0:-1]
        text_2 = text2[0:-1]
        count1 = longest_subseq(text1, text_2)
        count2 = longest_subseq(text2, text_1)
        return max(count1, count2)


from testing import assert_equal


fn main() raises:
    var text1: String = "abcde"
    var text2: String = "ace"
    result = longest_subseq(text1, text2)
    assert_equal(result, 3, "Assertion failed")

    text1 = "abc"
    text2 = "abc"
    result = longest_subseq(text1, text2)
    assert_equal(result, 3, "Assertion failed")

    text1 = "abc"
    text2 = "xyz"
    result = longest_subseq(text1, text2)
    assert_equal(result, 0, "Assertion failed")


```


[Source](https://github.com/ratulb/mojo_programming/blob/main/codes/longest_common_subeq.mojo)