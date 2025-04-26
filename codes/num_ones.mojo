### Count the number of set bits (Hamming weight) in the binary representation of a positive integer n.

fn count_bits(mut num: Int) -> Int:
	result = 0
	while num:
		result += num % 2
		num = num >> 1
	return result

from testing import assert_equal

fn main() raises:
	num = 11
	assert_equal(3, count_bits(num))
	num = 128
	assert_equal(1, count_bits(num))
	num = 2147483645
	assert_equal(30, count_bits(num))
