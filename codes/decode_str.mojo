"""
Decode String.

Given an encoded string, return its decoded string.  The encoding rule
is `k[encoded_string]` where the content inside brackets is repeated
`k` times.  Input is always well-formed; digits appear only as repeat
counts.  Nested encoding is supported.

**Algorithm** — O(n · k) where k is the repeat factor.

  Use a codepoint stack.  When a `]` is encountered:
    1. Pop from the stack until `[` is found — this recovers the
       encoded section (characters are popped in reverse, so we
       prepend to rebuild the correct order).
    2. Pop the `[` separator.
    3. Pop consecutive ASCII digits — these form the repeat count.
    4. Expand the section `count` times and push the result back
       onto the stack.

  After processing the entire string, the stack contains the fully
  decoded output.

Example:

    decode_str("3[a]2[bc]")      →  "aaabcbc"
    decode_str("3[a2[c]]")       →  "accaccacc"
    decode_str("2[abc]3[cd]ef")  →  "abcabccdcdcdef"
"""

from std.collections.string import Codepoint
from std.testing import assert_equal, TestSuite


# ═══════════════════════════════════════════════════════════════
#  Implementation
# ═══════════════════════════════════════════════════════════════

def decode_str(s: String) raises -> String:
    """Decode a `k[encoded_string]` pattern into its expanded form.

    Uses a stack-based approach: push codepoints until `]` is found,
    then unwind the innermost bracket to decode one level.  Nested
    brackets are handled automatically because the expanded content
    is pushed back onto the stack before the next `]` is processed.
    """
    var chars = [code for code in s.codepoints()]
    var length = len(chars)
    if length == 0 or length == 1:
        return s

    var stack = List[Codepoint](capacity=length)

    for ch in chars:
        if ch == Codepoint.ord("]"):
            # ── 1. Recover the section inside the brackets ──
            var section = String()
            while len(stack) > 0 and stack[len(stack) - 1] != Codepoint.ord("["):
                section = chr(Int(stack.pop())) + section

            # ── 2. Pop the opening bracket ──
            if len(stack) > 0:
                _ = stack.pop()

            # ── 3. Read the repeat count (digits before `[`) ──
            var count_str = String()
            while len(stack) > 0 and stack[len(stack) - 1].is_ascii_digit():
                count_str = chr(Int(stack.pop())) + count_str

            # ── 4. Expand and push back ──
            var times = Int(count_str)
            var expanded = String()
            for _ in range(times):
                expanded += section
            for code in expanded.codepoints():
                stack.append(code)
        else:
            stack.append(ch)

    var result = String()
    for code in stack:
        result.append(code)
    return result


# ═══════════════════════════════════════════════════════════════
#  Tests
# ═══════════════════════════════════════════════════════════════

def test_simple_repeat() raises:
    assert_equal(decode_str("3[a]"), "aaa")


def test_example_1() raises:
    assert_equal(decode_str("3[a]2[bc]"), "aaabcbc")


def test_example_2_nested() raises:
    assert_equal(decode_str("3[a2[c]]"), "accaccacc")


def test_example_3() raises:
    assert_equal(decode_str("2[abc]3[cd]ef"), "abcabccdcdcdef")


def test_single_char_no_repeat() raises:
    assert_equal(decode_str("a"), "a")


def test_empty_string() raises:
    assert_equal(decode_str(""), "")


def test_no_brackets() raises:
    assert_equal(decode_str("abcdef"), "abcdef")


def test_repeat_single_char() raises:
    assert_equal(decode_str("5[x]"), "xxxxx")


def test_double_nesting() raises:
    assert_equal(decode_str("2[3[a]]"), "aaaaaa")


def test_multiple_groups() raises:
    assert_equal(decode_str("2[a]3[b]4[c]"), "aabbbcccc")


def test_trailing_literal() raises:
    assert_equal(decode_str("2[ab]c"), "ababc")


def test_leading_literal() raises:
    assert_equal(decode_str("x4[y]z"), "xyyyyz")


def test_nested_with_literals() raises:
    assert_equal(decode_str("2[a3[b]c]"), "abbbcabbbc")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
