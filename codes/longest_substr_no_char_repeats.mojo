"""
Longest Substring Without Repeating Characters.

Given an ASCII string `s`, find the length of the longest contiguous
substring that contains no duplicate characters.

Uses a sliding-window approach with a `Set` to track characters in
the current window (O(n) time, O(min(n, |Σ|)) space).

Example:

    s = "abcabcbb"  →  3  ("abc")
    s = "bbbbb"     →  1  ("b")
    s = "pwwkew"    →  3  ("wke")
"""

from std.collections import Set
from std.testing import assert_equal, TestSuite


# ═══════════════════════════════════════════════════════════════
#  Sliding-window implementation
# ═══════════════════════════════════════════════════════════════

def len_longest_substr_no_char_repeats(ascii_s: String) raises -> Int:
    """Longest substring length with all unique characters (sliding window).

    Maintains a Set `seen` over the current window `[left, idx]`.
    When a duplicate character is encountered, shrink the window from
    the left until the duplicate is removed.
    """
    var s = ascii_s.as_bytes()
    var n = len(s)
    if n == 0:
        return 0

    # Seed the window with the first character.
    var seen = Set(s[0])
    var left = 0
    var max_length = 1

    for idx in range(1, n):
        # Shrink window from the left until the duplicate is gone.
        while s[idx] in seen:
            seen.remove(s[left])
            left += 1

        seen.add(s[idx])

        # Set size equals current window length (no duplicates).
        max_length = max(max_length, len(seen))

    return max_length


# ═══════════════════════════════════════════════════════════════
#  Tests
# ═══════════════════════════════════════════════════════════════

def test_example_cases() raises:
    assert_equal(len_longest_substr_no_char_repeats("abcabcbb"), 3)
    assert_equal(len_longest_substr_no_char_repeats("bbbbb"), 1)
    assert_equal(len_longest_substr_no_char_repeats("pwwkew"), 3)


def test_word_no_repeats() raises:
    assert_equal(len_longest_substr_no_char_repeats("current"), 4)


def test_empty_string() raises:
    assert_equal(len_longest_substr_no_char_repeats(""), 0)


def test_single_char() raises:
    assert_equal(len_longest_substr_no_char_repeats("a"), 1)


def test_two_unique_chars() raises:
    assert_equal(len_longest_substr_no_char_repeats("ab"), 2)


def test_two_same_chars() raises:
    assert_equal(len_longest_substr_no_char_repeats("aa"), 1)


def test_all_unique() raises:
    assert_equal(len_longest_substr_no_char_repeats("abcdef"), 6)


def test_repeat_at_end() raises:
    assert_equal(len_longest_substr_no_char_repeats("abca"), 3)


def test_repeat_in_middle() raises:
    assert_equal(len_longest_substr_no_char_repeats("abacdef"), 6)


def test_whole_string_is_answer() raises:
    assert_equal(len_longest_substr_no_char_repeats("abcdbef"), 5)


def test_special_chars() raises:
    assert_equal(len_longest_substr_no_char_repeats(" !@#$%"), 6)
    assert_equal(len_longest_substr_no_char_repeats("a b c"), 3)


def test_unicode_not_tested() raises:
    # Operates on raw bytes — multi-byte UTF-8 chars like 'é' (2 bytes)
    # are treated as distinct bytes, not a single character.
    assert_equal(len_longest_substr_no_char_repeats("café"), 5)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
