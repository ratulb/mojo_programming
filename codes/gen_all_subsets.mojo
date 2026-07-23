"""
Generate All Subsets.

Given an integer array `nums` that may contain duplicates, return all
possible subsets (the power set).  The solution set must not contain
duplicate subsets.

**Algorithm** — O(2ⁿ · n) time, O(2ⁿ · n) space (output size).

  Sort the array, then build subsets iteratively.  Start with a
  result containing only the empty subset.  For each element in
  the sorted array, extend every existing subset by appending the
  current element and add the new subsets to the result.

  To avoid generating duplicate subsets when the input contains
  duplicate values, track the number of subsets that existed
  *before* processing the first occurrence of a value.  When the
  same value appears again, only extend the subsets that were
  created since the previous occurrence, not the ones that already
  included an earlier copy.

Example:

    gen_all_subsets([1, 2, 2])  →  [[], [1], [1, 2], [1, 2, 2], [2], [2, 2]]
    gen_all_subsets([0])        →  [[], [0]]
"""

from std.testing import assert_equal, assert_false, assert_true, TestSuite


# ═══════════════════════════════════════════════════════════════
#  Implementation
# ═══════════════════════════════════════════════════════════════

def gen_all_subsets(mut nums: List[Int]) -> List[List[Int]]:
    """All subsets of `nums` (power set), with duplicate handling.

    Sort first, then build iteratively.  For each element, extend
    every existing subset by appending the element.  On duplicates,
    only extend subsets created since the previous occurrence to
    avoid generating identical subsets.
    """
    sort(nums)
    var result = List[List[Int]](capacity=2 ** len(nums))
    result.append(List[Int]())  # start with the empty subset

    var end: Int = 0
    for i in range(len(nums)):
        # If this is a duplicate, only extend subsets that were
        # created since the previous occurrence of this value.
        var start_idx: Int = 0
        if i > 0 and nums[i] == nums[i - 1]:
            start_idx = end
        end = len(result)
        for j in range(start_idx, end):
            var new_subset = result[j].copy()
            new_subset.append(nums[i])
            result.append(new_subset^)

    return result^



# ═══════════════════════════════════════════════════════════════
#  Tests
# ═══════════════════════════════════════════════════════════════

def test_example_with_duplicates() raises:
    var nums: List[Int] = [1, 2, 2]
    var result = gen_all_subsets(nums)
    assert_equal(len(result), 6)
    assert_true([] in result)
    assert_true([1] in result)
    assert_true([2] in result)
    assert_true([1, 2] in result)
    assert_true([2, 2] in result)
    assert_true([1, 2, 2] in result)


def test_example_single_element() raises:
    var nums: List[Int] = [0]
    var result = gen_all_subsets(nums)
    assert_equal(len(result), 2)
    assert_equal(result[0], [])
    assert_equal(result[1], [0])


def test_empty_array() raises:
    var nums = List[Int]()
    var result = gen_all_subsets(nums)
    assert_equal(len(result), 1)
    assert_equal(result[0], [])


def test_two_unique_elements() raises:
    var nums: List[Int] = [1, 3]
    var result = gen_all_subsets(nums)
    assert_equal(len(result), 4)
    assert_true([1] in result)
    assert_true([3] in result)
    assert_true([1, 3] in result)
    assert_true([] in result)


def test_all_duplicates() raises:
    var nums: List[Int] = [2, 2, 2]
    var result = gen_all_subsets(nums)
    assert_equal(len(result), 4)
    assert_equal(result[0], [])
    assert_equal(result[1], [2])
    assert_equal(result[2], [2, 2])
    assert_equal(result[3], [2, 2, 2])


def test_four_elements() raises:
    var nums: List[Int] = [1, 2, 3, 4]
    var result = gen_all_subsets(nums)
    assert_equal(len(result), 16)


def test_no_duplicate_subsets() raises:
    """All subsets in the result must be unique."""
    var nums: List[Int] = [1, 2, 2]
    var result = gen_all_subsets(nums)
    for i in range(len(result)):
        for j in range(i + 1, len(result)):
            assert_false(result[i] == result[j])


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
