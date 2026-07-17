"""
Group Anagrams.

Given an array of ASCII strings `strs`, group the anagrams together.
Two strings are anagrams if one can be rearranged to form the other
(i.e. they share the same character-frequency signature).

Two implementations are provided:

  1. `group_anagrams_by_sorting` — O(k·n log n) where k is the average
     string length and n is the number of strings.  Sorts each string's
     bytes to produce a canonical key.

  2. `group_anagrams` — O(k·n) counting sort.  Builds a 26-element
     frequency-vector key (assumes lowercase English letters).  Faster
     but restricted to that character set.

Example:

    strs = ["eat", "tea", "tan", "ate", "nat", "bat"]
    → [["bat"], ["nat", "tan"], ["ate", "eat", "tea"]]
"""

from std.testing import assert_equal, TestSuite


# ═══════════════════════════════════════════════════════════════
#  Approach 1 — sort each string's bytes
# ═══════════════════════════════════════════════════════════════

def group_anagrams_by_sorting(strs: List[String]) -> List[List[String]]:
    """Group anagrams using a sorted-bytes key.

    Each string is decomposed into its raw bytes, sorted
    lexicographically, and the resulting byte list is used as a
    dictionary key.  All strings sharing the same sorted key belong
    to the same anagram group.
    """
    if len(strs) == 0:
        return List[List[String]]()

    var groupings = Dict[List[UInt8], List[String]]()

    for s in strs:
        # Canonical key: sorted byte sequence of the string.
        var key = [byte for byte in s.bytes()]
        sort(key)

        # Retrieve existing group (or start a new one) and add `s`.
        var group = groupings.pop(key, List[String]())
        group.append(s)
        groupings[key^] = group^

    # Collect all groups.  Ownership of `groupings` is transferred
    # into the list comprehension so each group is moved out once.
    return [group.copy() for group in groupings^.values()]


# ═══════════════════════════════════════════════════════════════
#  Approach 2 — frequency-vector key (lowercase only)
# ═══════════════════════════════════════════════════════════════

def group_anagrams(strs: List[String]) -> List[List[String]]:
    """Group anagrams using a 26-slot frequency vector.

    Each string is reduced to a `List[Int]` of length 26 where slot
    `i` holds the count of character `chr(ord('a') + i)`.  Strings
    with identical frequency vectors are anagrams.

    NOTE: only works for lowercase English letters; any other byte
    will either silently index out of range or produce a wrong key.
    """
    if len(strs) == 0:
        return List[List[String]]()

    var groupings = Dict[List[Int], List[String]]()

    for s in strs:
        # Zero-initialised frequency vector, one slot per letter.
        var key = List[Int](length=26, fill=0)
        for code_point in s.codepoints():
            key[Int(code_point) - Int(Codepoint.ord("a"))] += 1

        var group = groupings.pop(key, List[String]())
        group.append(s)
        groupings[key^] = group^

    return [group.copy() for group in groupings^.values()]


# ═══════════════════════════════════════════════════════════════
#  Tests
# ═══════════════════════════════════════════════════════════════

# ── sorting-based approach ──────────────────────────────────

def test_sorting_example() raises:
    var result = group_anagrams_by_sorting(
        ["eat", "tea", "tan", "ate", "nat", "bat"]
    )
    assert_equal(len(result), 3)


def test_sorting_single() raises:
    var result = group_anagrams_by_sorting(["a"])
    assert_equal(len(result), 1)
    assert_equal(len(result[0]), 1)


def test_sorting_two_groups() raises:
    var result = group_anagrams_by_sorting(["a", "b"])
    assert_equal(len(result), 2)


def test_sorting_empty_input() raises:
    assert_equal(len(group_anagrams_by_sorting(List[String]())), 0)


def test_sorting_empty_string() raises:
    var result = group_anagrams_by_sorting([""])
    assert_equal(len(result), 1)
    assert_equal(len(result[0]), 1)
    assert_equal(result[0][0], "")


def test_sorting_all_same() raises:
    var result = group_anagrams_by_sorting(["abc", "cab", "bca"])
    assert_equal(len(result), 1)
    assert_equal(len(result[0]), 3)


# ── frequency-vector approach ───────────────────────────────

def test_freq_example() raises:
    var result = group_anagrams(
        ["eat", "tea", "tan", "ate", "nat", "bat"]
    )
    assert_equal(len(result), 3)


def test_freq_single() raises:
    var result = group_anagrams(["a"])
    assert_equal(len(result), 1)
    assert_equal(len(result[0]), 1)


def test_freq_two_groups() raises:
    var result = group_anagrams(["a", "b"])
    assert_equal(len(result), 2)


def test_freq_empty_input() raises:
    assert_equal(len(group_anagrams(List[String]())), 0)


def test_freq_empty_string() raises:
    var result = group_anagrams([""])
    assert_equal(len(result), 1)
    assert_equal(len(result[0]), 1)
    assert_equal(result[0][0], "")


def test_freq_all_same() raises:
    var result = group_anagrams(["abc", "cab", "bca"])
    assert_equal(len(result), 1)
    assert_equal(len(result[0]), 3)


def test_freq_repeated_strings() raises:
    var result = group_anagrams(["ab", "ab", "ba"])
    assert_equal(len(result), 1)
    assert_equal(len(result[0]), 3)


# ── cross-verification ──────────────────────────────────────

def test_both_implementations_agree() raises:
    # Test case 1: LeetCode example
    var case1 = List[String]()
    case1.append(String("eat"))
    case1.append(String("tea"))
    case1.append(String("tan"))
    case1.append(String("ate"))
    case1.append(String("nat"))
    case1.append(String("bat"))
    assert_equal(
        len(group_anagrams_by_sorting(case1)),
        len(group_anagrams(case1)),
    )

    # Test case 2: single element
    var case2 = List[String]()
    case2.append(String("a"))
    assert_equal(
        len(group_anagrams_by_sorting(case2)),
        len(group_anagrams(case2)),
    )

    # Test case 3: two separate groups
    var case3 = List[String]()
    case3.append(String("ab"))
    case3.append(String("ba"))
    case3.append(String("cd"))
    assert_equal(
        len(group_anagrams_by_sorting(case3)),
        len(group_anagrams(case3)),
    )

    # Test case 4: all same
    var case4 = List[String]()
    case4.append(String("abc"))
    case4.append(String("cab"))
    case4.append(String("bca"))
    assert_equal(
        len(group_anagrams_by_sorting(case4)),
        len(group_anagrams(case4)),
    )


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
