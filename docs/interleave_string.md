### Interleaving String
### Determine if s3 is an interleaving of s1 and s2.

```python


fn is_interleave(s1: String, s2: String, s3: String) -> Bool:
    if len(s1) + len(s2) != len(s3):
        return False
    dp = List[List[Bool]](
        length=len(s1) + 1, fill=List[Bool](length=len(s2) + 1, fill=False)
    )
    dp[len(s1)][len(s2)] = True
    for i in range(len(s1), -1, -1):
        for j in range(len(s2), -1, -1):
            if i < len(s1) and s1[i] == s3[i + j] and dp[i + 1][j]:
                dp[i][j] = True
            if j < len(s2) and s2[j] == s3[i + j] and dp[i][j + 1]:
                dp[i][j] = True

    return dp[0][0]


from testing import assert_true, assert_false


fn main() raises:
    var s1: String = "aabcc"
    var s2: String = "dbbca"
    var s3: String = "aadbbcbcac"
    result = is_interleave(s1, s2, s3)
    assert_true(result, "Assertion failed")

    s1 = "aabcc"
    s2 = "dbbca"
    s3 = "aadbbbaccc"
    result = is_interleave(s1, s2, s3)
    assert_false(result, "Assertion failed")

    s1 = ""
    s2 = ""
    s3 = ""
    result = is_interleave(s1, s2, s3)
    assert_true(result, "Assertion failed")

```


[Source](https://github.com/ratulb/mojo_programming/blob/main/codes/interleave_string.mojo)