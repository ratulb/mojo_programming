### Combination sum
### Find all unique combinations of numbers from candidates (reusable unlimited times) that sum to target.


fn combination_sum(candidates: List[Int], target: Int) -> List[List[Int]]:
    combinations = List[List[Int]]()
    if len(candidates) == 0:
        return combinations

    var curr_combination = List[Int]()
    find_combinations(candidates, 0, curr_combination, 0, target, combinations)
    return combinations

fn find_combinations(
    candidates: List[Int],
    curr_index: Int,
    mut curr_combination: List[Int],
    total: Int,
    target: Int,
    mut combinations: List[List[Int]],
):
    if total == target:
        copy = curr_combination.copy()
        sort(copy)  # For validation
        combinations.append(copy)
        return
    if curr_index >= len(candidates) or total > target:
        return
    curr_combination.append(candidates[curr_index])
    find_combinations(
        candidates,
        curr_index,
        curr_combination,
        total + candidates[curr_index],
        target,
        combinations,
    )
    _ = curr_combination.pop()
    find_combinations(
        candidates,
        curr_index + 1,
        curr_combination,
        total,
        target,
        combinations,
    )


from testing import assert_true


fn main() raises:
    candidates = List(2, 3, 6, 7)
    target = 7
    var result: List[List[Int]] = combination_sum(candidates, target)
    expected = List(2, 2, 3)
    count = 0
    for each in result:
        if each[] == expected:
            count += 1
    assert_true(count == 1, "assertion failed")
    expected = List(7)
    count = 0
    for each in result:
        if each[] == expected:
            count += 1
    assert_true(count == 1, "assertion failed")

    candidates = List(2, 3, 5)
    target = 8
    result = combination_sum(candidates, target)
    expected = List(2, 2, 2, 2)
    count = 0
    for each in result:
        if each[] == expected:
            count += 1
    assert_true(count == 1, "assertion failed")
    expected = List(2, 3, 3)
    count = 0
    for each in result:
        if each[] == expected:
            count += 1
    assert_true(count == 1, "assertion failed")
    expected = List(3, 5)
    count = 0
    for each in result:
        if each[] == expected:
            count += 1
    assert_true(count == 1, "assertion failed")
    candidates = List(2)
    target = 1
    result = combination_sum(candidates, target)
    assert_true(len(result) == 0, "assertion failed")
