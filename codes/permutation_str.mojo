"""
Permutations of a String.

Given an ASCII string `word`, return all possible permutations of its
characters.  The answer may be returned in any order.

Two implementations are provided:

  1. `permute_recursive` — O(n · n!) recursive backtracking.  For each
     character position, permute the remaining substring recursively,
     then append the selected character to each sub-permutation.

  2. `permute_iterative` — O(n · n!) incremental insertion.  Start with
     the last character, then repeatedly insert the next character at
     every possible position in every existing permutation.

Example:

    permute_recursive("abc")  →  [bca, cba, acb, cab, abc, bac]  (order varies)
    permute_iterative("abc")  →  [abc, bac, bca, acb, cab, cba]  (order varies)
"""

from std.collections import Set
from std.collections.string import Codepoint
from std.testing import assert_equal, assert_true, TestSuite


# ═══════════════════════════════════════════════════════════════
#  Approach 1 — recursive backtracking
# ═══════════════════════════════════════════════════════════════

def permute_recursive(word: String) -> List[String]:
    """Return all permutations of `word` via recursion.

    For each character at index `i`, build the string without that
    character (`prefix + suffix`), recursively find all permutations
    of that smaller string, then append character `i` to each result.
    """
    var codepoints = [codepoint for codepoint in word.codepoints()]
    var length = len(codepoints)
    if length == 0 or length == 1:
        return [word]

    var capacity = 1
    for i in range(2, length + 1):
        capacity *= i
    var perms = List[String](capacity=capacity)

    for i in range(length):
        # Build the string without the character at position i.
        var prefix = String()
        var suffix = String()
        for j in range(0, i):
            prefix.append(codepoints[j])
        for k in range(i + 1, length):
            suffix.append(codepoints[k])

        # Recursively permute the remaining characters.
        var intermediate_perms = permute_recursive(prefix + suffix)
        # Append the selected character to each sub-permutation.
        for ref perm in intermediate_perms:
            perm.append(codepoints[i])

        perms.extend(intermediate_perms^)

    return perms^


# ═══════════════════════════════════════════════════════════════
#  Approach 2 — iterative insertion
# ═══════════════════════════════════════════════════════════════

def permute_iterative(word: String) -> List[String]:
    """Return all permutations of `word` via incremental insertion.

    Start with a single permutation containing the last character.
    For each remaining character, insert it at every possible position
    in every existing permutation, building up the full set.
    """
    var stack = [chr(Int(codepoint)) for codepoint in word.codepoints()]
    if len(stack) == 0 or len(stack) == 1:
        return [word]

    # Seed with the last character.
    var perms = [stack.pop()]

    while stack:
        var letter = stack.pop()
        var incremental_perms: List[String] = []
        for perm in perms:
            var chars = [codepoint for codepoint in perm.codepoints()]
            # Insert `letter` at every possible position.
            for i in range(len(chars) + 1):
                var temp = String()
                for j in range(i):
                    temp.append(chars[j])
                temp.append(Codepoint.ord(letter))
                for k in range(i, len(chars)):
                    temp.append(chars[k])
                incremental_perms.append(temp^)
        perms = incremental_perms^

    return perms^


# ═══════════════════════════════════════════════════════════════
#  Helpers
# ═══════════════════════════════════════════════════════════════

def _is_permutation_of(subject: String, source: String) -> Bool:
    """Check that `subject` contains exactly the chars of `source`.

    Both strings must have the same length and the same multiset of
    Unicode codepoints.
    """
    if subject.count_codepoints() != source.count_codepoints():
        return False
    var sub_counts = Dict[Int, Int]()
    var src_counts = Dict[Int, Int]()
    for code in subject.codepoints():
        sub_counts[Int(code)] = sub_counts.get(Int(code), 0) + 1
    for code in source.codepoints():
        src_counts[Int(code)] = src_counts.get(Int(code), 0) + 1
    return sub_counts == src_counts


def _all_permutations_are_unique(perms: List[String]) -> Bool:
    """Return `True` if every string in `perms` is distinct."""
    var seen = Set[String]()
    for p in perms:
        if p in seen:
            return False
        seen.add(p)
    return True


# ═══════════════════════════════════════════════════════════════
#  Tests
# ═══════════════════════════════════════════════════════════════

# ── recursive approach ──────────────────────────────────────

def test_rec_example_three_chars() raises:
    var result = permute_recursive("abc")
    assert_equal(len(result), 6)
    for p in result:
        assert_true(_is_permutation_of(p, "abc"))
    assert_true(_all_permutations_are_unique(result))


def test_rec_single_char() raises:
    var result = permute_recursive("x")
    assert_equal(len(result), 1)
    assert_equal(result[0], "x")


def test_rec_two_chars() raises:
    var result = permute_recursive("ab")
    assert_equal(len(result), 2)
    assert_true(_all_permutations_are_unique(result))
    for p in result:
        assert_true(_is_permutation_of(p, "ab"))


def test_rec_empty_string() raises:
    var result = permute_recursive("")
    assert_equal(len(result), 1)
    assert_equal(result[0], "")


def test_rec_four_chars() raises:
    var result = permute_recursive("abcd")
    assert_equal(len(result), 24)
    assert_true(_all_permutations_are_unique(result))
    for p in result:
        assert_true(_is_permutation_of(p, "abcd"))


def test_rec_with_repeated_chars() raises:
    var result = permute_recursive("aab")
    # With duplicate chars, some permutations will be identical.
    assert_equal(len(result), 6)  # 6 variations, some may be duplicates
    for p in result:
        assert_true(_is_permutation_of(p, "aab"))


# ── iterative approach ──────────────────────────────────────

def test_iter_example_three_chars() raises:
    var result = permute_iterative("abc")
    assert_equal(len(result), 6)
    for p in result:
        assert_true(_is_permutation_of(p, "abc"))
    assert_true(_all_permutations_are_unique(result))


def test_iter_single_char() raises:
    var result = permute_iterative("z")
    assert_equal(len(result), 1)
    assert_equal(result[0], "z")


def test_iter_two_chars() raises:
    var result = permute_iterative("xy")
    assert_equal(len(result), 2)
    assert_true(_all_permutations_are_unique(result))


def test_iter_empty_string() raises:
    var result = permute_iterative("")
    assert_equal(len(result), 1)
    assert_equal(result[0], "")


def test_iter_four_chars() raises:
    var result = permute_iterative("efgh")
    assert_equal(len(result), 24)
    assert_true(_all_permutations_are_unique(result))


# ── cross-verification ──────────────────────────────────────

def test_both_implementations_produce_same_set() raises:
    var inputs = ["a", "ab", "abc", "xyz", "hello"]
    for word in inputs:
        var r1 = permute_recursive(word)
        var r2 = permute_iterative(word)
        assert_equal(len(r1), len(r2))
        # Both must contain the same set of strings.
        for p in r1:
            assert_true(p in r2)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
