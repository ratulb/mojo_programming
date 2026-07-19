"""
Longest Consecutive Sequence.

Given an unsorted array of integers `nums`, return the longest contiguous
sequence that can be formed from its elements (the sequence itself, not
just its length).  Runs in O(n) time.

**Algorithm** — O(n) time, O(n) space:

  1. Insert all numbers into a `Set` for O(1) membership checks.
  2. For each number, check if `n - 1` exists in the set.  If it does,
     `n` is *not* the start of a sequence — skip it.
  3. If `n` *is* a sequence start, walk upward (`n+1`, `n+2`, …) while
     consecutive numbers exist in the set, building the sequence.
  4. Keep the longest sequence seen.

This works because each number belongs to exactly one contiguous block,
and only the smallest element of each block triggers the walk, so every
element is examined at most twice (once in the outer loop, once during a
walk) — O(n) total.

Example:

    nums = [100, 4, 200, 1, 3, 2]  →  [1, 2, 3, 4]
    nums = [0, 3, 7, 2, 5, 8, 4, 6, 0, 1]  →  [0, 1, 2, 3, 4, 5, 6, 7, 8]
"""

from std.collections import Set
from std.testing import assert_equal, TestSuite


# ═══════════════════════════════════════════════════════════════
#  Implementation
# ═══════════════════════════════════════════════════════════════

def longest_consecutive_seq(nums: List[Int]) -> List[Int]:
    """Return the longest consecutive sequence contained in `nums`.

    Uses a hash set for O(1) lookups and only initiates a walk from
    numbers that are the start of a sequence (no predecessor in the
    set), guaranteeing O(n) overall time.
    """
    if len(nums) == 0 or len(nums) == 1:
        return nums.copy()

    var uniques = Set(nums)
    var longest: List[Int] = []

    for n in nums:
        # Only start a new sequence if n-1 is absent — otherwise n is
        # part of a block already being handled from a smaller start.
        if n - 1 not in uniques:
            var curr = [n]
            var next = n + 1
            while next in uniques:
                curr.append(next)
                next += 1
            longest = curr^ if len(curr) > len(longest) else longest^

    return longest^


# ═══════════════════════════════════════════════════════════════
#  Tests
# ═══════════════════════════════════════════════════════════════

def test_example_1() raises:
    assert_equal(
        longest_consecutive_seq([100, 4, 200, 1, 3, 2]),
        [1, 2, 3, 4],
    )


def test_example_2_with_duplicates() raises:
    assert_equal(
        longest_consecutive_seq([0, 3, 7, 2, 5, 8, 4, 6, 0, 1]),
        [0, 1, 2, 3, 4, 5, 6, 7, 8],
    )


def test_example_3() raises:
    assert_equal(
        longest_consecutive_seq([1, 0, 1, 2]),
        [0, 1, 2],
    )


def test_empty_input() raises:
    assert_equal(longest_consecutive_seq([]), [])


def test_single_element() raises:
    assert_equal(longest_consecutive_seq([42]), [42])


def test_two_consecutive() raises:
    assert_equal(longest_consecutive_seq([1, 2]), [1, 2])


def test_two_non_consecutive() raises:
    var result = longest_consecutive_seq([1, 3])
    assert_equal(len(result), 1)


def test_all_duplicates() raises:
    assert_equal(longest_consecutive_seq([5, 5, 5, 5]), [5])


def test_negative_numbers() raises:
    assert_equal(
        longest_consecutive_seq([-5, -4, -3, 0, 1]),
        [-5, -4, -3],
    )


def test_mixed_negatives_and_positives() raises:
    assert_equal(
        longest_consecutive_seq([-1, 0, 1, 5, 6, 7, 8]),
        [5, 6, 7, 8],
    )


def test_long_range_0_to_9() raises:
    assert_equal(
        longest_consecutive_seq([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]),
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    )


def test_unsorted_input() raises:
    assert_equal(
        longest_consecutive_seq([9, 3, 5, 4, 6, 7, 8, 2, 1, 0]),
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    )


def test_multiple_blocks() raises:
    var result = longest_consecutive_seq([10, 11, 12, 20, 21, 30])
    assert_equal(len(result), 3)


def test_single_is_also_longest_with_multi_element_blocks() raises:
    var result = longest_consecutive_seq([1, 10, 11, 20])
    assert_equal(len(result), 2)
    assert_equal(result, [10, 11])


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
