### Last word length
### Return the length of the last word in a given space-separated string

```python


fn last_word_length(s: String) -> Int:
    if len(s) == 0:
        return 0
    i, length = len(s) - 1, 0
    while i >= 0 and s[i] == " ":
        i -= 1
    while i >= 0 and s[i] != " ":
        length += 1
        i -= 1
    return length


fn main() raises:
    from testing import assert_true

    result = last_word_length("Hello World")
    assert_true(result == 5, "Assertion failed")

    result = last_word_length("         ")
    assert_true(result == 0, "Assertion failed")

    result = last_word_length("   fly me   to   the moon  ")
    assert_true(result == 4, "Assertion failed")

    result = last_word_length("luffy is still joyboy")
    assert_true(result == 6, "Assertion failed")

```


[Source](https://github.com/ratulb/mojo_programming/blob/main/codes/last_word_length.mojo)