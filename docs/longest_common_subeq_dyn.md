### Longest Common Subsequence Dynamic
### Return the length of the longest common subsequence between two strings, or 0 if none exists

```python


fn longest_subseq(mut text1: String, mut text2: String) raises -> Int:
    if len(text1) == 0 or len(text2) == 0:
        return 0
    dp = List[List[Int]](
        length=len(text1) + 1, fill=List[Int](length=len(text2) + 1, fill=0)
    )
    for i in range(len(text1) - 1, -1, -1):
        for j in range(len(text2) - 1, -1, -1):
            if text1[i] == text2[j]:
                dp[i][j] = 1 + dp[i + 1][j + 1]
            else:
                dp[i][j] = max(dp[i][j + 1], dp[i + 1][j])
    return dp[0][0]


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


[Source](https://github.com/ratulb/mojo_programming/blob/main/codes/longest_common_subeq_dyn.mojo)