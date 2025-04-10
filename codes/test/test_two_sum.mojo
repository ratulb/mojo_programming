from two_sum import *
from testing import assert_equal, assert_false, assert_raises, assert_true


def test_two_sum():
    nums = List(2, 7, 11, 15)
    target = 9
    indices = two_sum(nums, target)
    assert_true(indices[0] == 0 and indices[1] == 1, "Assertion failed")
    target = 18
    indices = two_sum(nums, target)
    assert_true(indices[0] == 1 and indices[1] == 2, "Assertion failed")
    target = 100
    indices = two_sum(nums, target)
    assert_false(indices[0] == -1 and indices[1] == -2, "Assertion failed")


def test_two_sum_raises():
    nums = List(2, 7, 11, 15)
    with assert_raises():
        target = 100
        indices = two_sum(nums, target)
        assert_true(indices[0] == -1 and indices[1] == -2, "Assertion failed")


def test_two_sum_costly():
    nums = List(2, 7, 11, 15)
    target = 9
    indices = two_sum_costly(nums, target)
    assert_true(indices[0] == 0 and indices[1] == 1, "Assertion failed")
    target = 18
    indices = two_sum_costly(nums, target)
    assert_true(indices[0] == 1 and indices[1] == 2, "Assertion failed")
    target = 100
    indices = two_sum_costly(nums, target)
    assert_false(indices[0] == -1 and indices[1] == -2, "Assertion failed")


def two_sum_costly_raises_test():
    nums = List(2, 7, 11, 15)
    with assert_raises():
        target = 100
        indices = two_sum_costly(nums, target)
        assert_true(indices[0] == -1 and indices[1] == -2, "Assertion failed")
