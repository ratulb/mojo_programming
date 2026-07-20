"""
Permutations.

Given an array of distinct integers `nums`, return all possible
permutations.  The answer may be returned in any order.

**Algorithm** — O(n · n!) time, O(n · n!) space (output size).

  Uses recursive backtracking:
    1. For each element in `nums`, pop it, recursively compute all
       permutations of the remaining n−1 elements, then append the
       popped element to each sub-permutation.
    2. Restore `nums` by appending the element back before the next
       iteration (backtracking step).
    3. Base case: a single-element list has exactly one permutation.

  The total number of permutations is n!.  The result list is
  pre-allocated to this capacity to avoid repeated resizing.

Example:

    permute([1, 2, 3])  →  [[1, 2, 3], [1, 3, 2], [2, 1, 3],
                             [2, 3, 1], [3, 1, 2], [3, 2, 1]]
    permute([0, 1])     →  [[0, 1], [1, 0]]
    permute([1])        →  [[1]]
"""

from std.testing import assert_equal, assert_true, TestSuite


# ═══════════════════════════════════════════════════════════════
#  Implementation
# ═══════════════════════════════════════════════════════════════

def permute(mut nums: List[Int]) -> List[List[Int]]:
    """Return all permutations of `nums` via recursive backtracking.

    The input list is mutated during recursion and restored before
    returning (the caller sees the original order).
    """
    if len(nums) == 1:
        return [nums.copy()]

    # Pre-compute capacity: n! is the exact number of permutations.
    var capacity = 1
    for i in range(2, len(nums) + 1):
        capacity *= i
    var result = List[List[Int]](capacity=capacity)

    for _ in range(len(nums)):
        # Take one element from the front.
        var n = nums.pop(0)

        # Recursively permute the remaining elements.
        var perms = permute(nums)
        # Append the removed element to every sub-permutation.
        for ref perm in perms:
            perm.append(n)

        # Collect all results and restore `nums` (backtrack).
        result.extend(perms^)
        nums.append(n)

    return result^


# ═══════════════════════════════════════════════════════════════
#  Helpers
# ═══════════════════════════════════════════════════════════════

def _is_permutation_of(perm: List[Int], original: List[Int]) -> Bool:
    """Check that `perm` contains exactly the elements of `original`."""
    if len(perm) != len(original):
        return False
    for x in original:
        if x not in perm:
            return False
    return True


def _all_permutations_are_unique(perms: List[List[Int]]) -> Bool:
    """Check that no two permutations in the list are identical."""
    for i in range(len(perms)):
        for j in range(i + 1, len(perms)):
            if perms[i] == perms[j]:
                return False
    return True


# ═══════════════════════════════════════════════════════════════
#  Tests
# ═══════════════════════════════════════════════════════════════

def test_example_1() raises:
    var nums: List[Int] = [1, 2, 3]
    var result = permute(nums)
    assert_equal(len(result), 6)
    for p in result:
        assert_true(_is_permutation_of(p, [1, 2, 3]))
    assert_true(_all_permutations_are_unique(result))


def test_example_2() raises:
    var nums: List[Int] = [0, 1]
    var result = permute(nums)
    assert_equal(len(result), 2)
    for p in result:
        assert_true(_is_permutation_of(p, [0, 1]))
    assert_true(_all_permutations_are_unique(result))


def test_single_element() raises:
    var nums: List[Int] = [42]
    var result = permute(nums)
    assert_equal(len(result), 1)
    assert_equal(result[0], [42])


def test_four_elements() raises:
    var nums: List[Int] = [1, 2, 3, 4]
    var result = permute(nums)
    assert_equal(len(result), 24)
    for p in result:
        assert_true(_is_permutation_of(p, [1, 2, 3, 4]))
    assert_true(_all_permutations_are_unique(result))


def test_two_elements_reversed() raises:
    var nums: List[Int] = [5, 10]
    var result = permute(nums)
    assert_equal(len(result), 2)
    assert_true(_all_permutations_are_unique(result))


def test_input_unchanged_after_call() raises:
    var nums: List[Int] = [1, 2, 3]
    var copy = nums.copy()
    _ = permute(nums)
    # The function should restore `nums` to its original state.
    assert_equal(nums, copy)


def test_negative_numbers() raises:
    var nums: List[Int] = [-1, 0, 1]
    var result = permute(nums)
    assert_equal(len(result), 6)
    for p in result:
        assert_true(_is_permutation_of(p, [-1, 0, 1]))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
