"""
Generate All Substrings.

Given an ASCII string, return every possible contiguous substring.
A substring is defined by a starting and ending index and is non-empty.

Three implementations are provided, each O(n²) time and O(n²) space
(since there are n(n+1)/2 substrings total):

  1. `gen_all_sub_strs_loop`             — nested for‑loop (most explicit).
  2. `gen_all_sub_strs_list_comprehension` — Mojo list comprehension.
  3. `gen_all_sub_strs_by_length`         — shortest substrings first.

Example:

    gen_all_sub_strs_loop("abc")
    → ["a", "ab", "abc", "b", "bc", "c"]
"""

from std.testing import assert_equal, TestSuite
from std.collections import Set


# ═══════════════════════════════════════════════════════════════
#  Implementations
# ═══════════════════════════════════════════════════════════════

def gen_all_sub_strs_loop(s: String) raises -> List[String]:
    """Generate all substrings via explicit nested loops (O(n²))."""
    var bytes = s.as_bytes()
    var n = len(bytes)

    # Pre-allocate capacity: n(n+1)/2 is the exact number of substrings.
    var substrings = List[String](capacity=((n * (n + 1)) // 2))

    for start in range(n):
        for end in range(start + 1, n + 1):
            # Span slice [start, end) is exclusive on the right.
            substrings.append(String(from_utf8=bytes[start:end]))

    return substrings^


def gen_all_sub_strs_list_comprehension(s: String) raises -> List[String]:
    """Generate all substrings using a Mojo list comprehension."""
    var bytes = s.as_bytes()
    var n = len(bytes)

    return [
        String(from_utf8=bytes[start:end])
        for start in range(n)
        for end in range(start + 1, n + 1)
    ]


def gen_all_sub_strs_by_length(s: String) raises -> List[String]:
    """Generate all substrings ordered by increasing length.

    Unlike the other two, this emits single-character substrings first,
    then pairs, triples, etc.  The order is useful when searching for
    the shortest substring matching some predicate (e.g. minimum window).
    """
    var n = s.byte_length()
    var substrings = List[String](capacity=((n * (n + 1)) // 2))

    for length in range(1, n + 1):
        # For a fixed length, every possible start offset
        # produces one substring of that exact length.
        for start in range(n - length + 1):
            var end = start + length
            substrings.append(String(s[byte=start:end]))

    return substrings^


# ═══════════════════════════════════════════════════════════════
#  Helpers
# ═══════════════════════════════════════════════════════════════

def string_list(items: List[StringSlice[StaticConstantOrigin]]) -> List[String]:
    """Convert literal string slices to a `List[String]` for testing."""
    var result = List[String](capacity=len(items))
    for item in items:
        result.append(String(item))
    return result^


# ═══════════════════════════════════════════════════════════════
#  Tests
# ═══════════════════════════════════════════════════════════════

def test_empty_string() raises:
    assert_equal(len(gen_all_sub_strs_loop("")), 0)
    assert_equal(len(gen_all_sub_strs_list_comprehension("")), 0)
    assert_equal(len(gen_all_sub_strs_by_length("")), 0)


def test_single_char() raises:
    var e = string_list(["a"])
    assert_equal(gen_all_sub_strs_loop("a"), e)
    assert_equal(gen_all_sub_strs_list_comprehension("a"), e)
    assert_equal(gen_all_sub_strs_by_length("a"), e)


def test_two_chars() raises:
    var e = string_list(["a", "ab", "b"])
    assert_equal(gen_all_sub_strs_loop("ab"), e)
    assert_equal(gen_all_sub_strs_list_comprehension("ab"), e)
    # gen_all_sub_strs_by_length uses a different order (tested separately)


def test_three_chars() raises:
    var e = string_list(["a", "ab", "abc", "b", "bc", "c"])
    assert_equal(gen_all_sub_strs_loop("abc"), e)
    assert_equal(gen_all_sub_strs_list_comprehension("abc"), e)


def test_all_implementations_agree() raises:
    var inputs = string_list(["", "a", "ab", "xyz", "hello", "abcde"])
    for s in inputs:
        var loop_result = gen_all_sub_strs_loop(s)
        var comp_result = gen_all_sub_strs_list_comprehension(s)
        var by_len_result = gen_all_sub_strs_by_length(s)

        # Loop and comprehension should produce identical order.
        assert_equal(loop_result, comp_result)

        # By-length may differ in order, but must contain the same set.
        assert_equal(
            Set(by_len_result),
            Set(loop_result),
        )


def test_by_length_order() raises:
    var e = string_list([
        "a", "b", "c", "d",            # length 1
        "ab", "bc", "cd",              # length 2
        "abc", "bcd",                   # length 3
        "abcd",                         # length 4
    ])
    assert_equal(gen_all_sub_strs_by_length("abcd"), e)


def test_substring_count() raises:
    # A string of length n has exactly n(n+1)/2 substrings.
    for n in range(1, 7):
        var s = String("x" * n)
        var expected_count = (n * (n + 1)) // 2
        assert_equal(len(gen_all_sub_strs_loop(s)), expected_count)
        assert_equal(len(gen_all_sub_strs_list_comprehension(s)), expected_count)
        assert_equal(len(gen_all_sub_strs_by_length(s)), expected_count)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
