"""
Evaluate Reverse Polish Notation.

Evaluate the value of an arithmetic expression expressed in Reverse Polish
Notation (postfix notation).  In RPN the operator follows its operands,
eliminating the need for parentheses.

The expression is given as a list of strings, each entry being either an
integer or one of the four operators `+`, `-`, `*`, `/`.

Algorithm — O(n) time, O(n) space:

  1. Iterate tokens left to right.
  2. If the token is an operator, pop two values from the stack (right
     operand first, then left), apply the operation, and push the result.
  3. Otherwise the token represents an integer — push it onto the stack.
  4. After all tokens have been consumed the stack holds exactly one
     value: the result.

Division truncates toward zero (e.g. `-3 / 2 = -1`), matching the
convention used by LeetCode problem 150.

Example:

    tokens = ["15", "7", "1", "1", "+", "-", "/", "3", "*",
              "2", "1", "1", "+", "+", "-"]

    Evaluates to 5, equivalent to:
        ((15 / (7 - (1 + 1))) * 3) - (2 + (1 + 1))
"""

from std.testing import assert_equal, assert_true, TestSuite


# ── helpers ────────────────────────────────────────────────────

def is_operator(token: StaticString) -> Bool:
    return token == "+" or token == "-" or token == "*" or token == "/"


def trunc_div(a: Int, b: Int) -> Int:
    """Integer division truncating toward zero.

    LeetCode RPN (`/`) requires truncation toward zero (e.g. `-3 / 2 = -1`),
    but Mojo's `//` performs floor division, which rounds toward negative
    infinity (e.g. `-3 // 2 = -2`).

    The correction: when the operands have opposite signs and the division
    is inexact, floor rounded one step too far in the negative direction —
    adding 1 recovers truncation toward zero.
    """
    var q = a // b
    if (a < 0) != (b < 0) and q * b != a:
        q += 1
    return q


# ── evaluator ──────────────────────────────────────────────────

def eval_rpn(tokens: List[StaticString]) raises -> Int:
    var stack = List[Int](capacity=len(tokens))
    for token in tokens:
        if is_operator(token):
            var right = stack.pop()
            var left = stack.pop()
            if token == "+":
                stack.append(left + right)
            elif token == "-":
                stack.append(left - right)
            elif token == "*":
                stack.append(left * right)
            else:
                stack.append(trunc_div(left, right))
        else:
            stack.append(Int(token))
    return stack[0]


# ── tests ──────────────────────────────────────────────────────

def test_simple_add() raises:
    assert_equal(eval_rpn(["5", "3", "+"]), 8)


def test_simple_sub() raises:
    assert_equal(eval_rpn(["10", "4", "-"]), 6)


def test_simple_mul() raises:
    assert_equal(eval_rpn(["2", "3", "*"]), 6)


def test_simple_div() raises:
    assert_equal(eval_rpn(["8", "4", "/"]), 2)


def test_complex_example() raises:
    assert_equal(
        eval_rpn([
            "15", "7", "1", "1", "+", "-", "/", "3", "*",
            "2", "1", "1", "+", "+", "-",
        ]),
        5,
    )


def test_multi_ops() raises:
    assert_equal(eval_rpn(["2", "1", "+", "3", "*"]), 9)
    assert_equal(eval_rpn(["4", "13", "5", "/", "+"]), 6)


def test_negative_result() raises:
    assert_equal(eval_rpn(["1", "5", "-"]), -4)


def test_negative_operands() raises:
    assert_equal(eval_rpn(["-2", "5", "+"]), 3)
    assert_equal(eval_rpn(["-2", "-3", "+"]), -5)


def test_division_trunc_toward_zero() raises:
    assert_equal(eval_rpn(["-6", "4", "/"]), -1)
    assert_equal(eval_rpn(["6", "-4", "/"]), -1)
    assert_equal(eval_rpn(["-6", "-4", "/"]), 1)
    assert_equal(eval_rpn(["-7", "2", "/"]), -3)


def test_all_four_ops() raises:
    assert_equal(eval_rpn(["2", "3", "+", "5", "*", "4", "-"]), 21)


def test_single_element() raises:
    assert_equal(eval_rpn(["42"]), 42)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
