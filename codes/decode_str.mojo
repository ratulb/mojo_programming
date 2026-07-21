"""
Decode String.

Given an encoded string, return its decoded string.  The encoding rule
is `k[encoded_string]` where the content inside brackets is repeated
`k` times.  Input is always well-formed; digits appear only as repeat
counts.  Nested encoding is supported.

Two implementations are provided — both O(n · k):

  • `decode_str` — character stack.  Push codepoints until `]`;
    unwind the innermost bracket, expand, and push the result
    back.  Handles nesting naturally because expanded content is
    available before the next `]` is processed.

  • `decode_str_two_stack` — count + string stacks.  Walk the
    input with a byte pointer; push (current_string, count) onto
    stacks at `[`; pop and append count times at `]`.  Avoids
    unwinding character-by-character from the stack.

Example:

    decode_str("3[a]2[bc]")      →  "aaabcbc"
    decode_str("3[a2[c]]")       →  "accaccacc"
    decode_str("2[abc]3[cd]ef")  →  "abcabccdcdcdef"
"""

from std.collections.string import Codepoint
from std.testing import assert_equal, TestSuite


# ═══════════════════════════════════════════════════════════════
#  Approach 1 — character stack
# ═══════════════════════════════════════════════════════════════

def decode_str(s: String) raises -> String:
    """Decode using a single codepoint stack.

    Push characters until `]`.  On `]`, pop back to `[` to recover
    the section, read the repeat count from the digits before `[`,
    expand the section, and push the expanded result back onto the
    stack.  After the full pass the stack holds the decoded string.
    """
    var chars = s.codepoints()
    if len(chars) == 0 or len(chars) == 1:
        return s

    var stack = List[Codepoint](capacity=len(chars))

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
#  Approach 2 — count + string stacks
# ═══════════════════════════════════════════════════════════════

def decode_str_two_stack(s: String) raises -> String:
    """Decode using count and string stacks (LeetCode 394 style).

    Walk the input byte-by-byte:
      • digit → accumulate the full multi-digit number and push it.
      • `[`  → push the current string onto the stack; reset.
      • `]`  → pop count and previous string; append current count
               times; result becomes the new current string.
      • else → append the byte as a codepoint to the current string.
    """
    var bytes = s.as_bytes()
    var n = len(bytes)
    if n == 0 or n == 1:
        return s

    var count_stack = List[Int]()
    var str_stack = List[String]()
    var current = String()
    var i = 0
    comptime ascii_zero = UInt8(48)

    while i < n:
        var b = bytes[i]

        if ascii_zero <= b <= UInt8(57):  # '0' … '9'
            var num = 0
            while i < n and ascii_zero <= bytes[i] <= UInt8(57):
                num = num * 10 + Int(bytes[i]) - Int(ascii_zero)
                i += 1
            count_stack.append(num)

        elif b == UInt8(Int(Codepoint.ord("["))):
            str_stack.append(current^)
            current = String()
            i += 1

        elif b == UInt8(Int(Codepoint.ord("]"))):
            var times = count_stack.pop()
            var prev = str_stack.pop()
            for _ in range(times):
                prev += current
            current = prev^
            i += 1

        else:
            current.append(Codepoint(b))
            i += 1

    return current


# ═══════════════════════════════════════════════════════════════
#  Tests
# ═══════════════════════════════════════════════════════════════

# ── character-stack approach ────────────────────────────────

def test_cs_simple_repeat() raises:
    assert_equal(decode_str("3[a]"), "aaa")


def test_cs_example_1() raises:
    assert_equal(decode_str("3[a]2[bc]"), "aaabcbc")


def test_cs_example_2_nested() raises:
    assert_equal(decode_str("3[a2[c]]"), "accaccacc")


def test_cs_example_3() raises:
    assert_equal(decode_str("2[abc]3[cd]ef"), "abcabccdcdcdef")


def test_cs_single_char_no_repeat() raises:
    assert_equal(decode_str("a"), "a")


def test_cs_empty_string() raises:
    assert_equal(decode_str(""), "")


def test_cs_no_brackets() raises:
    assert_equal(decode_str("abcdef"), "abcdef")


def test_cs_repeat_single_char() raises:
    assert_equal(decode_str("5[x]"), "xxxxx")


def test_cs_double_nesting() raises:
    assert_equal(decode_str("2[3[a]]"), "aaaaaa")


def test_cs_multiple_groups() raises:
    assert_equal(decode_str("2[a]3[b]4[c]"), "aabbbcccc")


def test_cs_trailing_literal() raises:
    assert_equal(decode_str("2[ab]c"), "ababc")


def test_cs_leading_literal() raises:
    assert_equal(decode_str("x4[y]z"), "xyyyyz")


def test_cs_nested_with_literals() raises:
    assert_equal(decode_str("2[a3[b]c]"), "abbbcabbbc")


# ── two-stack approach ──────────────────────────────────────

def test_ts_example_1() raises:
    assert_equal(decode_str_two_stack("3[a]2[bc]"), "aaabcbc")


def test_ts_example_2_nested() raises:
    assert_equal(decode_str_two_stack("3[a2[c]]"), "accaccacc")


def test_ts_example_3() raises:
    assert_equal(decode_str_two_stack("2[abc]3[cd]ef"), "abcabccdcdcdef")


def test_ts_empty_string() raises:
    assert_equal(decode_str_two_stack(""), "")


def test_ts_single_char() raises:
    assert_equal(decode_str_two_stack("a"), "a")


def test_ts_repeat() raises:
    assert_equal(decode_str_two_stack("5[x]"), "xxxxx")


def test_ts_nested() raises:
    assert_equal(decode_str_two_stack("2[3[a]]"), "aaaaaa")


def test_ts_multi_digit_count() raises:
    assert_equal(decode_str_two_stack("12[a]"), "aaaaaaaaaaaa")


def test_ts_large_expansion() raises:
    assert_equal(decode_str_two_stack("3[ab]"), "ababab")


def test_ts_leading_trailing_literals() raises:
    assert_equal(decode_str_two_stack("x4[y]z"), "xyyyyz")


# ── cross-verification ──────────────────────────────────────

def test_both_implementations_agree() raises:
    var inputs = List[String]()
    inputs.append(String("3[a]2[bc]"))
    inputs.append(String("3[a2[c]]"))
    inputs.append(String("2[abc]3[cd]ef"))
    inputs.append(String("5[x]"))
    inputs.append(String("2[3[a]]"))
    inputs.append(String("x4[y]z"))
    inputs.append(String("2[a3[b]c]"))
    for s in inputs:
        assert_equal(decode_str(s), decode_str_two_stack(s))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
