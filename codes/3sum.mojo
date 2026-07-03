"""
3SUM
Given an integer array, find all unique triplets `(i, j, k)` such that `nums[i] + nums[j] + nums[k] = 0`.
Each triplet is returned with both the values and their original indices.

**Approach: Sort + Two Pointers**

A naive O(n³) triple loop checks every combination. We can do better:

1. Pair each value with its original index, then sort by value.
2. Fix one element as the pivot. For each pivot, use two pointers (`left`, `right`) on the remaining subarray.
3. If the three sum to zero — record the triplet, move both pointers, and skip duplicates.
4. If the sum is too low, advance `left`; if too high, retreat `right`.
5. Early exit: if the pivot value exceeds 0, no later triplet can sum to 0.

This runs in O(n²) time and O(n) space (or O(1) extra ignoring the sort).

A brute-force O(n³) version (`find_triplets_bruteforce`) is also included for comparison.
"""
from std.random import shuffle
from std.collections import InlineArray

comptime Triplet = InlineArray[Tuple[Int, Int], 3]


# Comparison function used for sorting the array of tuples (value, original_index)
@parameter
def compare_fn(left: Tuple[Int, Int], right: Tuple[Int, Int]) -> Bool:
    return (
        left[0] < right[0]
    )  # Compare based on the actual value, not the index


# Function to find all unique triplets that sum up to 0
def find_triplets(nums: List[Int]) -> List[Triplet]:
    # Create a new list of tuples (value, original index)
    var numbers = List[Tuple[Int, Int]](capacity=len(nums))
    for idx in range(len(nums)):
        numbers.append((nums[idx], idx))  # Keep original index

    # Sort the list based on the value of elements
    sort[compare_fn](numbers)

    # List to store the result triplets
    var result: List[Triplet] = []

    # Iterate through the sorted list using a fixed pivot at index `idx`
    for idx in range(len(numbers) - 2):
        # Early stopping: if current value is greater than 0, we can't find a sum of 0
        if numbers[idx][0] > 0:
            break
        # Skip duplicates: avoid repeated first elements to prevent repeated triplets
        if idx > 0 and numbers[idx][0] == numbers[idx - 1][0]:
            continue

        # Two-pointer approach starts here
        var left, right = idx + 1, len(numbers) - 1
        while left < right:
            # Calculate sum of the triplet
            sum = numbers[idx][0] + numbers[left][0] + numbers[right][0]
            if sum == 0:
                # Found a valid triplet that sums to 0
                result.append(
                    # Triplet(numbers[idx], numbers[left], numbers[right])
                    [numbers[idx], numbers[left], numbers[right]]
                )
                # Move both pointers inward
                left += 1
                right -= 1

                # Skip duplicates after finding a valid triplet
                while left < right and numbers[left - 1][0] == numbers[left][0]:
                    left += 1
                while (
                    left < right and numbers[right][0] == numbers[right + 1][0]
                ):
                    right -= 1
            elif sum < 0:
                # Sum is too small, move left pointer to increase it
                left += 1
            else:
                # Sum is too large, move right pointer to decrease it
                right -= 1

    return result^


# O(n³) brute-force version — checks every (i, j, k) with i < j < k
def find_triplets_bruteforce(nums: List[Int]) -> List[Triplet]:
    var result: List[Triplet] = []
    for i in range(len(nums) - 2):
        for j in range(i + 1, len(nums) - 1):
            for k in range(j + 1, len(nums)):
                if nums[i] + nums[j] + nums[k] == 0:
                    result.append([(nums[i], i), (nums[j], j), (nums[k], k)])
    return result^


# Helper function to nicely print triplet values and their original indices
def pretty_print(triplets: List[Triplet]):
    for triplet in triplets:
        print("Elem1 value: ", triplet[0][0], ", index: ", triplet[0][1])
        print("Elem2 value: ", triplet[1][0], ", index: ", triplet[1][1])
        print("Elem3 value: ", triplet[2][0], ", index: ", triplet[2][1])
        print()


# Comparator for sorting Tuple[Int, Int, Int] lexicographically
@parameter
def cmp_tuple3(a: Tuple[Int, Int, Int], b: Tuple[Int, Int, Int]) -> Bool:
    if a[0] != b[0]:
        return a[0] < b[0]
    if a[1] != b[1]:
        return a[1] < b[1]
    return a[2] < b[2]


# Convert each Triplet to a sorted (a, b, c) value-tuple, discarding indices
def normalize(triplets: List[Triplet]) -> List[Tuple[Int, Int, Int]]:
    var result = List[Tuple[Int, Int, Int]]()
    for t in triplets:
        var a = t[0][0]
        var b = t[1][0]
        var c = t[2][0]
        if a > b:
            (a, b) = (b, a)
        if b > c:
            (b, c) = (c, b)
        if a > b:
            (a, b) = (b, a)
        result.append((a, b, c))
    return result^


# Remove adjacent duplicates from a sorted list of value-triplets
def dedup_sorted(
    vals: List[Tuple[Int, Int, Int]]
) -> List[Tuple[Int, Int, Int]]:
    if len(vals) == 0:
        return List[Tuple[Int, Int, Int]]()
    var result = List[Tuple[Int, Int, Int]]()
    result.append(vals[0])
    for i in range(1, len(vals)):
        if vals[i] != vals[i - 1]:
            result.append(vals[i])
    return result^


# Entry point: generates a test list, runs both versions, prints results
def main():
    var list = [-3, -3, -2, -1, 0, 1, 2, 2, 3]
    shuffle(list)

    print("Sorted + Two Pointers:")
    var triplets = find_triplets(list)
    pretty_print(triplets)

    print("Brute-force O(n³):")
    var brute = find_triplets_bruteforce(list)
    pretty_print(brute)

    print("--- Verification ---")
    var n1 = normalize(triplets)
    var n2 = normalize(brute)
    sort[cmp_tuple3](n1)
    sort[cmp_tuple3](n2)
    n2 = dedup_sorted(n2)

    if len(n1) != len(n2):
        print("FAIL: length mismatch (", len(n1), "vs", len(n2), ")")
        return
    for i in range(len(n1)):
        if n1[i] != n2[i]:
            print("FAIL: mismatch at", i)
            return
    print("PASS: both versions produce the same", len(n1), "unique triplets")
