"""
Reverse String.

Reverse a string by iterating its Unicode codepoints in reverse order.

Algorithm — O(n) time and space.

  1. Collect all codepoints into a list.
  2. Iterate from the last index down to 0, appending each codepoint
     to a result `String`.

Example:

    reverse("abc")  →  "cba"
    reverse("")     →  ""
"""

from std.testing import assert_equal, TestSuite


# ═══════════════════════════════════════════════════════════════
#  Implementation
# ═══════════════════════════════════════════════════════════════

def reverse(s: String) -> String:
    """Return `s` with its Unicode codepoints reversed.

    Works on full Unicode codepoints (not raw bytes), so multi-byte
    characters are preserved correctly.
    """
    var codepoints = List[Codepoint](capacity=s.byte_length())
    for code in s.codepoints():
        codepoints.append(code)

    if len(codepoints) == 0 or len(codepoints) == 1:
        return s

    var result = String()
    for i in range(len(codepoints) - 1, -1, -1):
        result.append(codepoints[i])

    return result


# ═══════════════════════════════════════════════════════════════
#  Tests
# ═══════════════════════════════════════════════════════════════

def test_empty_string() raises:
    assert_equal(reverse(""), "")


def test_single_char() raises:
    assert_equal(reverse("a"), "a")


def test_two_chars() raises:
    assert_equal(reverse("ab"), "ba")


def test_three_chars() raises:
    assert_equal(reverse("abc"), "cba")


def test_palindrome() raises:
    assert_equal(reverse("racecar"), "racecar")


def test_with_spaces() raises:
    assert_equal(reverse("hello world"), "dlrow olleh")


def test_unicode_multi_byte() raises:
    assert_equal(reverse("café"), "éfac")


def test_unicode_emoji() raises:
    assert_equal(reverse("a😊b"), "b😊a")


def test_numbers_and_symbols() raises:
    assert_equal(reverse("123!@#"), "#@!321")


def test_reverse_twice_returns_original() raises:
    var original = "Hello, 世界! 😊"
    assert_equal(reverse(reverse(original)), original)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
