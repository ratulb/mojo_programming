"""
Generate All Subsets (no duplicates).

Given an integer array `nums` of distinct integers, return all possible
subsets (the power set).

Two implementations are provided — both O(2ⁿ · n) time and space:

  • `gen_all_subsets` — iterative extension.  Start with `[[]]` and
    for each element extend every existing subset by appending it.

  • `gen_all_subsets_recursive` — recursive backtracking via a
    helper function with explicit `mut` parameters (no `capturing`
    nested function, avoiding a Mojo compiler crash with nested
    closures).

Example:

    gen_all_subsets([1, 2, 3])  →  [[], [1], [2], [1, 2], [3], [1, 3], [2, 3], [1, 2, 3]]
"""

from std.testing import assert_equal, assert_false, assert_true, TestSuite


# ═══════════════════════════════════════════════════════════════
#  Helpers
# ═══════════════════════════════════════════════════════════════

def _backtrack(
    mut nums: List[Int],
    start: Int,
    mut subset: List[Int],
    mut result: List[List[Int]],
):
    """Recursive helper — appends every node of the recursion tree.

    At each call, the current `subset` is a valid subset and is
    appended to `result`.  Then we try adding each remaining element
    and recurse.
    """
    result.append(subset.copy())

    for i in range(start, len(nums)):
        subset.append(nums[i])
        _backtrack(nums, i + 1, subset, result)
        _ = subset.pop()


# ═══════════════════════════════════════════════════════════════
#  Approach 1 — iterative
# ═══════════════════════════════════════════════════════════════

def gen_all_subsets(mut nums: List[Int]) -> List[List[Int]]:
    """All subsets via iterative extension (no recursion).

    Sort first (though input is already distinct), then for each
    element extend every existing subset by appending it.
    """
    sort(nums)
    var result = List[List[Int]](capacity=2 ** len(nums))
    result.append(List[Int]())

    for i in range(len(nums)):
        var end = len(result)
        for j in range(end):
            var new_subset = result[j].copy()
            new_subset.append(nums[i])
            result.append(new_subset^)

    return result^


# ═══════════════════════════════════════════════════════════════
#  Approach 2 — recursive (no capturing)
# ═══════════════════════════════════════════════════════════════

def gen_all_subsets_recursive(mut nums: List[Int]) -> List[List[Int]]:
    """All subsets via recursive backtracking.

    Uses a plain helper function with `mut` parameters instead of
    a `capturing` nested function to avoid Mojo compiler issues
    with closures.
    """
    sort(nums)
    var result = List[List[Int]](capacity=2 ** len(nums))
    var subset = List[Int]()
    _backtrack(nums, 0, subset, result)
    return result^


# ═══════════════════════════════════════════════════════════════
#  Tests
# ═══════════════════════════════════════════════════════════════

def _check_power_set(result: List[List[Int]], nums: List[Int]) raises:
    """Assert that `result` is a valid power set of `nums`."""
    assert_equal(len(result), 2 ** len(nums))
    for p in result:
        for x in p:
            assert_true(x in nums)
    for i in range(len(result)):
        for j in range(i + 1, len(result)):
            assert_false(result[i] == result[j])


# ── iterative ───────────────────────────────────────────────

def test_iter_example_three_elements() raises:
    var nums: List[Int] = [1, 2, 3]
    var result = gen_all_subsets(nums)
    assert_equal(len(result), 8)
    _check_power_set(result, [1, 2, 3])


def test_iter_single_element() raises:
    var nums: List[Int] = [5]
    var result = gen_all_subsets(nums)
    assert_equal(len(result), 2)
    _check_power_set(result, [5])


def test_iter_empty_array() raises:
    var nums = List[Int]()
    var result = gen_all_subsets(nums)
    assert_equal(len(result), 1)
    assert_equal(result[0], [])


def test_iter_four_elements() raises:
    var nums: List[Int] = [10, 20, 30, 40]
    var result = gen_all_subsets(nums)
    assert_equal(len(result), 16)
    _check_power_set(result, nums)


# ── recursive ───────────────────────────────────────────────

def test_rec_example_three_elements() raises:
    var nums: List[Int] = [1, 2, 3]
    var result = gen_all_subsets_recursive(nums)
    assert_equal(len(result), 8)
    _check_power_set(result, [1, 2, 3])


def test_rec_single_element() raises:
    var nums: List[Int] = [7]
    var result = gen_all_subsets_recursive(nums)
    assert_equal(len(result), 2)
    _check_power_set(result, [7])


def test_rec_empty_array() raises:
    var nums = List[Int]()
    var result = gen_all_subsets_recursive(nums)
    assert_equal(len(result), 1)
    assert_equal(result[0], [])


def test_rec_four_elements() raises:
    var nums: List[Int] = [2, 4, 6, 8]
    var result = gen_all_subsets_recursive(nums)
    assert_equal(len(result), 16)
    _check_power_set(result, nums)


# ── cross-verification ──────────────────────────────────────

def test_both_agree_empty() raises:
    var a = List[Int]()
    var r1 = gen_all_subsets(a)
    var b = List[Int]()
    var r2 = gen_all_subsets_recursive(b)
    assert_equal(len(r1), len(r2))


def test_both_agree_single() raises:
    var a: List[Int] = [5]
    var r1 = gen_all_subsets(a)
    var b: List[Int] = [5]
    var r2 = gen_all_subsets_recursive(b)
    for x in r1: assert_true(x in r2)
    for x in r2: assert_true(x in r1)


def test_both_agree_two() raises:
    var a: List[Int] = [1, 2]
    var r1 = gen_all_subsets(a)
    var b: List[Int] = [1, 2]
    var r2 = gen_all_subsets_recursive(b)
    assert_equal(len(r1), len(r2))


def test_both_agree_three() raises:
    var a: List[Int] = [1, 2, 3]
    var r1 = gen_all_subsets(a)
    var b: List[Int] = [1, 2, 3]
    var r2 = gen_all_subsets_recursive(b)
    for x in r1: assert_true(x in r2)
    for x in r2: assert_true(x in r1)


def test_both_agree_four() raises:
    var a: List[Int] = [10, 20, 30, 40]
    var r1 = gen_all_subsets(a)
    var b: List[Int] = [10, 20, 30, 40]
    var r2 = gen_all_subsets_recursive(b)
    assert_equal(len(r1), len(r2))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
