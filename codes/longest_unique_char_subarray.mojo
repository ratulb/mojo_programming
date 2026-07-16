"""
Longest Unique-Character Subarray.

Given an ASCII string `s`, return the longest contiguous substring that
contains no repeated characters.

Uses a sliding-window with a `Dict` mapping each character to its most
recent index (O(n) time, O(min(n, |Σ|)) space).

This is the "return the substring" variant of the classic problem —
compare with `longest_substr_no_char_repeats` which returns only the
length.

Example:

    s = "12345678911"  →  "123456789"
    s = "abcabcbb"     →  "abc"
"""

from std.testing import assert_equal, TestSuite


# ═══════════════════════════════════════════════════════════════
#  Sliding-window implementation
# ═══════════════════════════════════════════════════════════════

def longest_unique_char_subarray(s: String) raises -> String:
    """Longest substring with all unique characters (returns substring).

    Expands the window one character at a time (`right` pointer).
    When a duplicate is found, the `left` pointer jumps past the
    previous occurrence, maintaining a duplicate-free window.
    Tracks the start and length of the longest window seen.
    """
    var bytes = s.as_bytes()
    var n = len(bytes)
    if n == 0 or n == 1:
        return s

    # Map each byte to its most recent index in the current window.
    var seen = Dict[UInt8, Int]()
    var left = 0
    var max_start = 0
    var max_length = 0

    for right, char in enumerate(bytes):
        # If char was seen inside the current window, jump past it.
        if char in seen and seen[char] >= left:
            left = seen[char] + 1

        # Record (or update) the position of this character.
        seen[char] = right

        var curr_length = right - left + 1
        if curr_length > max_length:
            max_length = curr_length
            max_start = left

    return String(from_utf8=bytes[max_start : max_start + max_length])


# ═══════════════════════════════════════════════════════════════
#  Tests
# ═══════════════════════════════════════════════════════════════

def test_example_with_numbers() raises:
    assert_equal(longest_unique_char_subarray("12345678911"), "123456789")


def test_example_abcabcbb() raises:
    assert_equal(longest_unique_char_subarray("abcabcbb"), "abc")


def test_example_bbbbb() raises:
    assert_equal(longest_unique_char_subarray("bbbbb"), "b")


def test_example_pwwkew() raises:
    assert_equal(longest_unique_char_subarray("pwwkew"), "wke")


def test_empty_string() raises:
    assert_equal(longest_unique_char_subarray(""), "")


def test_single_char() raises:
    assert_equal(longest_unique_char_subarray("x"), "x")


def test_two_unique() raises:
    assert_equal(longest_unique_char_subarray("ab"), "ab")


def test_two_same() raises:
    assert_equal(longest_unique_char_subarray("aa"), "a")


def test_all_unique() raises:
    assert_equal(longest_unique_char_subarray("abcdef"), "abcdef")


def test_answer_in_middle() raises:
    assert_equal(longest_unique_char_subarray("abca"), "abc")


def test_answer_at_end() raises:
    assert_equal(longest_unique_char_subarray("aabc"), "abc")


def test_longer_substring_later() raises:
    assert_equal(longest_unique_char_subarray("abacdef"), "bacdef")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
