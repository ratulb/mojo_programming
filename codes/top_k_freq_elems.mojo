"""
Top K Frequent Elements.

Given an integer array `nums` and an integer `k`, return the `k` most
frequent elements.  The answer may be returned in any order.

Two implementations are provided:

  1. `top_k_frequent` — O(n log n) using a max-heap.  Count frequencies
     with a `Dict`, push each (element, count) pair onto a max-heap,
     then pop the top `k`.

  2. `top_k` — O(n) using bucket sort.  Uses the frequency as an index
     into a bucket array of length `len(nums) + 1` (the maximum possible
     frequency).  Iterate buckets from highest frequency downward,
     collecting elements until `k` are gathered.

Example:

    nums = [1, 1, 1, 2, 2, 3],  k = 2  →  [1, 2]
    nums = [1],                 k = 1  →  [1]
"""

from std.collections.binary_heap import BinaryHeap
from std.testing import assert_equal, assert_true, TestSuite


# ═══════════════════════════════════════════════════════════════
#  Helper — heap element (frequency-tracking pair)
# ═══════════════════════════════════════════════════════════════

@fieldwise_init
struct Pair(Copyable & Comparable & ImplicitlyDeletable):
    """(element, frequency) pair ordered by frequency for a max-heap.

    BinaryHeap is a max-heap — the element with the largest `__lt__`
    "wins".  We define `__lt__` to compare frequencies so that the
    pair with the highest frequency sits at the top.
    """
    var pair: Tuple[Int, Int]

    def __lt__(self: Self, rhs: Self) -> Bool:
        return self.pair[1] < rhs.pair[1]

    def __eq__(self: Self, other: Self) -> Bool:
        return self.pair[1] == other.pair[1]


# ═══════════════════════════════════════════════════════════════
#  Approach 1 — max-heap (O(n log n))
# ═══════════════════════════════════════════════════════════════

def top_k_frequent(nums: List[Int], k: Int) -> List[Int]:
    """Top `k` frequent elements via a max-heap.

    1. Build a frequency dict.
    2. Push every (element, frequency) pair onto a max-heap.
    3. Pop the top `k` elements — these are the k most frequent.
    """
    if len(nums) == 0 or not k > 0 or len(nums) < k:
        return []
    var freqs = Dict[Int, Int]()

    for num in nums:
        freqs[num] = 1 + freqs.get(num, 0)

    if len(freqs) < k:
        return []

    var heap = BinaryHeap[Pair]()
    # Transfer ownership of freqs to avoid retaining the dict.
    for item in freqs^.items():
        heap.push(Pair((item.key, item.value)))

    var result = List[Int](capacity=k)
    for _ in range(k):
        # Pop returns the pair with highest frequency.
        result.append(heap.pop().pair[0])

    return result^


# ═══════════════════════════════════════════════════════════════
#  Approach 2 — bucket sort (O(n))
# ═══════════════════════════════════════════════════════════════

def top_k(nums: List[Int], k: Int) -> List[Int]:
    """Top `k` frequent elements via bucket sort.

    1. Build a frequency dict.
    2. Use the frequency as an index into a bucket array (`bucket`).
       A number appearing `f` times is placed in bucket `f`.
    3. Walk buckets from highest frequency downward, collecting elements
       until `k` are gathered.
    """
    if len(nums) == 0 or not k > 0 or len(nums) < k:
        return []
    var freqs = Dict[Int, Int]()

    for num in nums:
        freqs[num] = 1 + freqs.get(num, 0)

    if len(freqs) < k:
        return []

    # Bucket array: index = frequency, value = list of elements with that freq.
    # NOTE: `List[List[Int]]` with `fill` shares the inner list across all slots,
    # so we must build each bucket independently to avoid cross-bucket aliasing.
    var bucket = List[List[Int]](capacity=len(nums) + 1)
    for _ in range(len(nums) + 1):
        bucket.append(List[Int]())
    for item in freqs.items():
        var num = item.key
        var index = item.value
        bucket[index].append(num)

    var result = List[Int](capacity=k)

    # Walk from highest possible frequency down to 1.
    for right in range(len(bucket) - 1, 0, -1):
        for n in bucket[right]:
            result.append(n)
            if len(result) == k:
                return result^
    return result^


# ═══════════════════════════════════════════════════════════════
#  Tests
# ═══════════════════════════════════════════════════════════════

# ── max-heap approach ───────────────────────────────────────

def test_heap_example_1() raises:
    assert_equal(top_k_frequent([1, 1, 1, 2, 2, 3], 2), [1, 2])


def test_heap_example_2() raises:
    assert_equal(top_k_frequent([1], 1), [1])


def test_heap_example_3() raises:
    var result = top_k_frequent([1, 2, 1, 2, 1, 2, 3, 1, 3, 2], 2)
    assert_equal(len(result), 2)
    assert_true(1 in result)
    assert_true(2 in result)


def test_heap_k_larger_than_unique() raises:
    assert_equal(top_k_frequent([1, 1, 2], 5), [])


def test_heap_empty_input() raises:
    assert_equal(top_k_frequent([], 1), [])


def test_heap_all_same_frequency() raises:
    var result = top_k_frequent([1, 2, 3, 4], 2)
    assert_equal(len(result), 2)


def test_heap_single_repeated() raises:
    assert_equal(top_k_frequent([5, 5, 5, 5], 1), [5])


def test_heap_k_is_zero() raises:
    assert_equal(top_k_frequent([1, 2, 3], 0), [])


def test_heap_negative_k() raises:
    assert_equal(top_k_frequent([1, 2, 3], -1), [])


def test_heap_negative_numbers() raises:
    var result = top_k_frequent([-1, -1, -2, -2, -2, -3], 2)
    assert_equal(len(result), 2)
    assert_true(-2 in result)


# ── bucket-sort approach ────────────────────────────────────

def test_bucket_example_1() raises:
    assert_equal(top_k([1, 1, 1, 2, 2, 3], 2), [1, 2])


def test_bucket_example_2() raises:
    assert_equal(top_k([1], 1), [1])


def test_bucket_example_3() raises:
    var result = top_k([1, 2, 1, 2, 1, 2, 3, 1, 3, 2], 2)
    assert_equal(len(result), 2)
    assert_true(1 in result)
    assert_true(2 in result)


def test_bucket_k_larger_than_unique() raises:
    assert_equal(top_k([1, 1, 2], 5), [])


def test_bucket_empty_input() raises:
    assert_equal(top_k([], 1), [])


def test_bucket_all_same_frequency() raises:
    var result = top_k([1, 2, 3, 4], 2)
    assert_equal(len(result), 2)


def test_bucket_single_repeated() raises:
    assert_equal(top_k([5, 5, 5, 5], 1), [5])


def test_bucket_k_is_zero() raises:
    assert_equal(top_k([1, 2, 3], 0), [])


def test_bucket_negative_k() raises:
    assert_equal(top_k([1, 2, 3], -1), [])


def test_bucket_negative_numbers() raises:
    var result = top_k([-1, -1, -2, -2, -2, -3], 2)
    assert_equal(len(result), 2)
    assert_true(-2 in result)


# ── cross-verification ──────────────────────────────────────

def _top_k_freq(nums: List[Int], k: Int, idx: Int) -> Int:
    """Compute the k-th highest frequency in `nums`.

    Used to verify that an implementation's answer consists solely of
    elements whose frequency is at least this threshold.
    """
    var freqs = Dict[Int, Int]()
    for num in nums:
        freqs[num] = 1 + freqs.get(num, 0)
    var freq_list = List[Int](capacity=len(freqs))
    for item in freqs.items():
        freq_list.append(item.value)
    sort(freq_list)  # ascending
    return freq_list[len(freq_list) - k]


def _valid_top_k_result(nums: List[Int], k: Int, result: List[Int]) -> Bool:
    """Check that `result` is a valid answer for the top-k problem.

    Every element in `result` must have frequency >= the k-th highest
    frequency in `nums`.  This accommodates ties where different
    implementations may pick different elements.
    """
    if len(result) != k:
        return False
    var threshold = _top_k_freq(nums, k, 0)
    var freqs = Dict[Int, Int]()
    for num in nums:
        freqs[num] = 1 + freqs.get(num, 0)
    for x in result:
        if freqs.get(x, 0) < threshold:
            return False
    return True


def test_heap_only_valid_results() raises:
    var cases = List[List[Int]]()
    var ks = List[Int]()
    cases.append([1, 1, 1, 2, 2, 3]);           ks.append(2)
    cases.append([1]);                          ks.append(1)
    cases.append([1, 2, 1, 2, 1, 2, 3, 1, 3, 2]); ks.append(2)
    cases.append([5, 5, 5, 5]);                 ks.append(1)
    cases.append([1, 2, 3, 4]);                 ks.append(2)
    cases.append([-1, -1, -2, -2, -2, -3]);    ks.append(2)
    cases.append([1, 1, 2, 2, 3, 3, 3]);       ks.append(2)
    for i in range(len(cases)):
        assert_true(
            _valid_top_k_result(cases[i], ks[i], top_k_frequent(cases[i], ks[i]))
        )


def test_bucket_only_valid_results() raises:
    var cases = List[List[Int]]()
    var ks = List[Int]()
    cases.append([1, 1, 1, 2, 2, 3]);           ks.append(2)
    cases.append([1]);                          ks.append(1)
    cases.append([1, 2, 1, 2, 1, 2, 3, 1, 3, 2]); ks.append(2)
    cases.append([5, 5, 5, 5]);                 ks.append(1)
    cases.append([1, 2, 3, 4]);                 ks.append(2)
    cases.append([-1, -1, -2, -2, -2, -3]);    ks.append(2)
    cases.append([1, 1, 2, 2, 3, 3, 3]);       ks.append(2)
    for i in range(len(cases)):
        assert_true(
            _valid_top_k_result(cases[i], ks[i], top_k(cases[i], ks[i]))
        )


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
