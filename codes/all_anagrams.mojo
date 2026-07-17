"""
Find All Anagrams in a String.

Given two ASCII strings `s` and `p`, return a list of all start indices
of `p`'s anagrams in `s`.  An anagram is a permutation of the characters
of `p`, so any contiguous substring of `s` whose character-frequency
dict matches that of `p` is a match.

Uses a fixed-length sliding-window — the window size equals `len(p)`.
At each step the character-frequency dict of the window is compared
against the target dict (O(n) time, O(|Σ|) space).

Example:

    s = "cbaebabacd", p = "abc"  →  [0, 6]
    s = "abab",        p = "ab"  →  [0, 1, 2]
"""

from std.testing import assert_equal, TestSuite


# ═══════════════════════════════════════════════════════════════
#  Sliding-window implementation
# ═══════════════════════════════════════════════════════════════

def find_anagrams(s: String, p: String) -> List[Int]:
    """All start indices in `s` where a permutation of `p` occurs.

    Builds a frequency dict for `p`, then slides a window of the same
    length across `s`, maintaining a parallel frequency dict for the
    current window.  When the two dicts are equal the window is an
    anagram match.
    """
    var s_bytes = s.as_bytes()
    var p_bytes = p.as_bytes()
    var s_len = len(s_bytes)
    var p_len = len(p_bytes)

    if s_len < p_len or p_len == 0:
        return List[Int]()

    # Build frequency dicts for the first window.
    var p_freq = Dict[UInt8, Int]()
    var win_freq = Dict[UInt8, Int]()
    for i in range(p_len):
        p_freq[p_bytes[i]] = 1 + p_freq.get(p_bytes[i], 0)
        win_freq[s_bytes[i]] = 1 + win_freq.get(s_bytes[i], 0)

    var result = [0] if p_freq == win_freq else List[Int]()
    var left: Int = 0
    var right = p_len

    # Slide the window one position at a time.
    while right < s_len:
        # Add the incoming character on the right.
        win_freq[s_bytes[right]] = 1 + win_freq.get(s_bytes[right], 0)

        # Remove the outgoing character on the left.
        win_freq[s_bytes[left]] = win_freq.get(s_bytes[left], 1) - 1
        # Clean up zero-count entries to keep dicts comparable.
        if win_freq.get(s_bytes[left], 0) == 0:
            _ = win_freq.pop(
                s_bytes[left], -1
            )  # default -1 is ignored on success

        right += 1
        left += 1

        if p_freq == win_freq:
            result.append(left)

    return result^


# ═══════════════════════════════════════════════════════════════
#  Tests
# ═══════════════════════════════════════════════════════════════

def test_basic_exact_match() raises:
    assert_equal(find_anagrams("abc", "abc"), [0])


def test_reordered_match() raises:
    assert_equal(find_anagrams("cba", "abc"), [0])


def test_extra_char_after() raises:
    assert_equal(find_anagrams("cbaa", "abc"), [0])


def test_two_matches() raises:
    assert_equal(find_anagrams("cbaacb", "abc"), [0, 3])


def test_cbaebabacd_example() raises:
    assert_equal(find_anagrams("cbaebabacd", "abc"), [0, 6])


def test_abab_example() raises:
    assert_equal(find_anagrams("abab", "ab"), [0, 1, 2])


def test_no_match() raises:
    assert_equal(find_anagrams("abcdef", "xyz"), List[Int]())


def test_target_longer_than_source() raises:
    assert_equal(find_anagrams("ab", "abc"), List[Int]())


def test_single_chars() raises:
    assert_equal(find_anagrams("aaa", "a"), [0, 1, 2])


def test_single_char_no_match() raises:
    assert_equal(find_anagrams("bbb", "a"), List[Int]())


def test_target_at_end() raises:
    assert_equal(find_anagrams("xyzabc", "abc"), [3])


def test_target_at_start() raises:
    assert_equal(find_anagrams("abcxyz", "abc"), [0])


def test_overlapping_windows() raises:
    assert_equal(find_anagrams("aaaa", "aa"), [0, 1, 2])


def test_empty_source() raises:
    assert_equal(find_anagrams("", "a"), List[Int]())


def test_empty_target() raises:
    assert_equal(find_anagrams("abc", ""), List[Int]())


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
