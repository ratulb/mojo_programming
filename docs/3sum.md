### Find all unique triplets [a, b, c] in the array such that a + b + c = 0.
### This solution also returns indices of the triplets along with their values

```python

import random
from collections import InlineArray

# Define a fixed-size array type to store triplets: each element is a tuple (value: Int, index: UInt)
alias Triplet = InlineArray[(Int, UInt), 3]


# Comparison function used for sorting the array of tuples (value, original_index)
@parameter
fn compare_fn(left: (Int, UInt), right: (Int, UInt)) -> Bool:
    return (
        left[0] < right[0]
    )  # Compare based on the actual value, not the index


# Function to find all unique triplets that sum up to 0
fn find_triplets(nums: List[Int]) -> List[Triplet]:
    # Create a new list of tuples (value, original index)
    numbers = List[(Int, UInt)](capacity=len(nums))
    for idx in range(len(nums)):
        numbers.append((nums[idx], UInt(idx)))  # Keep original index

    # Sort the list based on the value of elements
    sort[compare_fn](numbers)

    # List to store the result triplets
    outcome = List[Triplet]()

    # Iterate through the sorted list using a fixed pivot at index `idx`
    for idx in range(len(numbers) - 2):
        # Early stopping: if current value is greater than 0, we can't find a sum of 0
        if numbers[idx][0] > 0:
            break
        # Skip duplicates: avoid repeated first elements to prevent repeated triplets
        if idx > 0 and numbers[idx][0] == numbers[idx - 1][0]:
            continue

        # Two-pointer approach starts here
        left, right = idx + 1, len(numbers) - 1
        while left < right:
            # Calculate sum of the triplet
            sum = numbers[idx][0] + numbers[left][0] + numbers[right][0]
            if sum == 0:
                # Found a valid triplet that sums to 0
                outcome.append(
                    Triplet(numbers[idx], numbers[left], numbers[right])
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

    return outcome


# Helper function to nicely print triplet values and their original indices
fn pretty_print(triplets: List[Triplet]):
    for triplet in triplets:
        print("Elem1 value: ", triplet[][0][0], ", index: ", triplet[][0][1])
        print("Elem2 value: ", triplet[][1][0], ", index: ", triplet[][1][1])
        print("Elem3 value: ", triplet[][2][0], ", index: ", triplet[][2][1])
        print()


# Entry point: generates a test list, shuffles it, finds triplets and prints them
fn main():
    list = List(-3, -3, -2, -1, 0, 1, 2, 2, 3)
    random.shuffle(list)  # Randomize input to simulate unordered input
    triplets = find_triplets(list)
    pretty_print(triplets)

```


[Source](https://github.com/ratulb/mojo_programming/blob/main/codes/3sum.mojo)
