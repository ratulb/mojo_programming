"""
Longest Increasing Subsequence.

Given an integer array `nums`, find the length of the longest strictly
increasing subsequence (LIS), and return the subsequence itself.

Two functions are provided:

  • `length_of_lis` — O(n²) DP, returns only the *length*.
  • `longest_increasing_subsequence` — same DP but also reconstructs
    the actual sequence by tracking the next index in the chain.

**Algorithm** — O(n²) time, O(n) space:

  `dp[i]` = length of the longest strictly increasing subsequence
  *starting* at index `i`.  Process indices from right to left; for
  each `j > i` where `nums[i] < nums[j]`, update
  `dp[i] = max(dp[i], 1 + dp[j])`.

  The sequence-reconstruction variant maintains a `next_idx[i]` array:
  when `1 + dp[j] > dp[i]`, set `next_idx[i] = j`.  After the DP pass,
  find the index with the maximum `dp` value and walk forward through
  the `next_idx` pointers.

Example:

    length_of_lis([10, 9, 2, 5, 3, 7, 101, 18])  →  4
    longest_increasing_subsequence(...)            →  [2, 5, 7, 101]
"""

from std.testing import assert_equal, assert_true, TestSuite


# ═══════════════════════════════════════════════════════════════
#  Length-only (standard DP)
# ═══════════════════════════════════════════════════════════════

def length_of_lis(nums: List[Int]) -> Int:
    """Length of the longest strictly increasing subsequence.

    DP scanning right-to-left: `dp[i]` = LIS length starting at `i`.
    Base: every element alone forms a subsequence of length 1.
    """
    var n = len(nums)
    if n == 0 or n == 1:
        return n

    var dp = List[Int](length=n, fill=1)

    for i in range(n - 1, -1, -1):
        for j in range(i + 1, n):
            if nums[i] < nums[j]:
                dp[i] = max(dp[i], 1 + dp[j])

    var max_len = dp[0]
    for i in range(1, n):
        max_len = max(max_len, dp[i])
    return max_len


# ═══════════════════════════════════════════════════════════════
#  Sequence reconstruction
# ═══════════════════════════════════════════════════════════════

def longest_increasing_subsequence(nums: List[Int]) -> List[Int]:
    """Return the longest strictly increasing subsequence itself.

    Uses the same right-to-left DP as `length_of_lis`, but additionally
    tracks the next index in the optimal chain so the sequence can be
    reconstructed by a forward walk.
    """
    var n = len(nums)
    if n == 0:
        return List[Int]()
    if n == 1:
        return nums.copy()

    var dp = List[Int](length=n, fill=1)
    var next_idx = List[Int](length=n, fill=-1)

    for i in range(n - 1, -1, -1):
        for j in range(i + 1, n):
            if nums[i] < nums[j] and 1 + dp[j] > dp[i]:
                dp[i] = 1 + dp[j]
                next_idx[i] = j

    # Find the starting index of the longest sequence.
    var start = 0
    for i in range(1, n):
        if dp[i] > dp[start]:
            start = i

    # Walk forward through next_idx pointers to reconstruct.
    var result = List[Int](capacity=dp[start])
    var curr = start
    while curr >= 0:
        result.append(nums[curr])
        curr = next_idx[curr]

    return result^


# ═══════════════════════════════════════════════════════════════
#  Helpers
# ═══════════════════════════════════════════════════════════════

def _is_strictly_incr(seq: List[Int]) -> Bool:
    for i in range(1, len(seq)):
        if seq[i - 1] >= seq[i]:
            return False
    return True


def _is_subsequence_of(sub: List[Int], sup: List[Int]) -> Bool:
    """Check that `sub` appears in order within `sup`."""
    var si = 0
    for x in sup:
        if si < len(sub) and sub[si] == x:
            si += 1
    return si == len(sub)


# ═══════════════════════════════════════════════════════════════
#  Tests
# ═══════════════════════════════════════════════════════════════

# ── length_of_lis ───────────────────────────────────────────

def test_len_example_1() raises:
    assert_equal(length_of_lis([10, 9, 2, 5, 3, 7, 101, 18]), 4)


def test_len_example_2() raises:
    assert_equal(length_of_lis([0, 1, 0, 3, 2, 3]), 4)


def test_len_example_3() raises:
    assert_equal(length_of_lis([7, 7, 7, 7, 7, 7, 7]), 1)


def test_len_empty() raises:
    assert_equal(length_of_lis([]), 0)


def test_len_single() raises:
    assert_equal(length_of_lis([5]), 1)


def test_len_decreasing() raises:
    assert_equal(length_of_lis([5, 4, 3, 2, 1]), 1)


def test_len_negative() raises:
    assert_equal(length_of_lis([-2, -1, 0, 5]), 4)


# ── longest_increasing_subsequence ──────────────────────────

def test_seq_example_1() raises:
    var result = longest_increasing_subsequence([10, 9, 2, 5, 3, 7, 101, 18])
    assert_equal(len(result), 4)
    assert_true(_is_strictly_incr(result))
    assert_true(_is_subsequence_of(result, [10, 9, 2, 5, 3, 7, 101, 18]))


def test_seq_example_2() raises:
    var result = longest_increasing_subsequence([0, 1, 0, 3, 2, 3])
    assert_equal(len(result), 4)
    assert_true(_is_strictly_incr(result))
    assert_true(_is_subsequence_of(result, [0, 1, 0, 3, 2, 3]))


def test_seq_example_3() raises:
    var result = longest_increasing_subsequence([7, 7, 7, 7, 7, 7, 7])
    assert_equal(len(result), 1)
    assert_true(_is_strictly_incr(result))
    assert_true(_is_subsequence_of(result, [7, 7, 7, 7, 7, 7, 7]))


def test_seq_empty() raises:
    assert_equal(len(longest_increasing_subsequence([])), 0)


def test_seq_single() raises:
    assert_equal(longest_increasing_subsequence([42]), [42])


def test_seq_decreasing() raises:
    var result = longest_increasing_subsequence([5, 4, 3, 2, 1])
    assert_equal(len(result), 1)
    assert_true(_is_subsequence_of(result, [5, 4, 3, 2, 1]))


def test_seq_negative() raises:
    var result = longest_increasing_subsequence([-2, -1, 0, 5])
    assert_equal(result, [-2, -1, 0, 5])


def test_seq_simple_ascending() raises:
    assert_equal(longest_increasing_subsequence([1, 2, 3, 4]), [1, 2, 3, 4])


def test_seq_matches_length_of_lis() raises:
    var case0: List[Int] = [10, 9, 2, 5, 3, 7, 101, 18]
    assert_equal(length_of_lis(case0), len(longest_increasing_subsequence(case0)))

    var case1: List[Int] = [0, 1, 0, 3, 2, 3]
    assert_equal(length_of_lis(case1), len(longest_increasing_subsequence(case1)))

    var case2: List[Int] = [7, 7, 7, 7, 7, 7, 7]
    assert_equal(length_of_lis(case2), len(longest_increasing_subsequence(case2)))

    var case3 = List[Int]()
    assert_equal(length_of_lis(case3), len(longest_increasing_subsequence(case3)))

    var case4: List[Int] = [5]
    assert_equal(length_of_lis(case4), len(longest_increasing_subsequence(case4)))

    var case5: List[Int] = [5, 4, 3, 2, 1]
    assert_equal(length_of_lis(case5), len(longest_increasing_subsequence(case5)))

    var case6: List[Int] = [-2, -1, 0, 5]
    assert_equal(length_of_lis(case6), len(longest_increasing_subsequence(case6)))

    var case7: List[Int] = [1, 2, 3, 4]
    assert_equal(length_of_lis(case7), len(longest_increasing_subsequence(case7)))

    var case8: List[Int] = [3, 1, 4, 1, 5, 9, 2, 6, 5]
    assert_equal(length_of_lis(case8), len(longest_increasing_subsequence(case8)))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
