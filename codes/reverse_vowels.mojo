"""
Reverse Vowels of a String.

Given a string `s`, reverse only the vowels in the string and return it.
Vowels are `a`, `e`, `i`, `o`, `u` in both lower and upper case.

Algorithm — O(n) time, O(n) space:

  Use two pointers (`left`, `right`) starting at both ends of the
  codepoint list.  Advance each pointer inward until it lands on a
  vowel, then swap the two vowels and continue.  When the pointers
  cross, all vowels have been reversed while consonants stay in
  place.

Example:

    s = "IceCreAm"   →   "AceCreIm"
    s = "leetcode"   →   "leotcede"
"""

from std.collections import Set
from std.collections.string import Codepoint
from std.testing import assert_equal, TestSuite


# ═══════════════════════════════════════════════════════════════
#  Implementation
# ═══════════════════════════════════════════════════════════════

def reverse_vowels(s: String) -> String:
    """Reverse only the vowels in `s`, leaving consonants in place."""
    var codepoints = [code for code in s.codepoints()]
    var n = len(codepoints)
    if n == 0 or n == 1:
        return s

    var vowels = Set([Int(code) for code in "aeiouAEIOU".codepoints()])

    var left = 0
    var right = n - 1

    while left < right:
        # Advance left until it lands on a vowel.
        while left < right and Int(codepoints[left]) not in vowels:
            left += 1

        # Advance right until it lands on a vowel.
        while left < right and Int(codepoints[right]) not in vowels:
            right -= 1

        if left < right:
            codepoints.swap_elements(left, right)
            left += 1
            right -= 1

    var result = String()
    for code in codepoints:
        result.append(code)

    return result


# ═══════════════════════════════════════════════════════════════
#  Tests
# ═══════════════════════════════════════════════════════════════

def test_example_1() raises:
    assert_equal(reverse_vowels("IceCreAm"), "AceCreIm")


def test_example_2() raises:
    assert_equal(reverse_vowels("leetcode"), "leotcede")


def test_empty_string() raises:
    assert_equal(reverse_vowels(""), "")


def test_single_char_consonant() raises:
    assert_equal(reverse_vowels("b"), "b")


def test_single_char_vowel() raises:
    assert_equal(reverse_vowels("a"), "a")


def test_no_vowels() raises:
    assert_equal(reverse_vowels("bcdfg"), "bcdfg")


def test_all_vowels() raises:
    assert_equal(reverse_vowels("aeiou"), "uoiea")


def test_vowels_in_mixed_case() raises:
    assert_equal(reverse_vowels("AEIOU"), "UOIEA")


def test_only_middle_vowel() raises:
    assert_equal(reverse_vowels("abcd"), "abcd")


def test_multiple_vowels_odd_length() raises:
    assert_equal(reverse_vowels("hello"), "holle")


def test_vowels_at_ends() raises:
    assert_equal(reverse_vowels("amazing"), "imazang")


def test_palindrome_with_vowels() raises:
    assert_equal(reverse_vowels("racecar"), "racecar")


def test_spaces_and_punctuation() raises:
    assert_equal(reverse_vowels("a!e@i#o$u%"), "u!o@i#e$a%")


def test_uppercase_and_lowercase() raises:
    # Vowels are reversed as-is; case stays with each character.
    assert_equal(reverse_vowels("AaEeIiOoUu"), "uUoOiIeEaA")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
