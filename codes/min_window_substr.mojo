"""
Minimum Window Substring.

Given a string `s` and a target string `t`, find the shortest contiguous
substring of `s` that contains every character from `t` (including
multiplicity).  If no such window exists, return `None`.

This file provides two implementations:

  • `min_window` — O(n) sliding-window algorithm (primary solution).
  • `min_window_bruteforce` — O(n³) reference that checks every possible
    window (kept for correctness verification).

Example:

    s = "ADOBECODEBANC",  t = "ABC"
    → "BANC"
"""

from std.testing import assert_equal, TestSuite


# ═══════════════════════════════════════════════════════════════
#  O(n) sliding-window solution
# ═══════════════════════════════════════════════════════════════

def min_window(s: String, t: String) raises -> Optional[String]:
    """Shortest substring of `s` containing all chars in `t` (sliding window)."""
    var source_bytes = s.as_bytes()
    var target_bytes = t.as_bytes()
    var source_length = len(source_bytes)
    var target_length = len(target_bytes)

    if source_length == 0 or target_length == 0 or source_length < target_length:
        return None

    # Build frequency dict for target characters.
    var target_freq = Dict[UInt8, Int]()
    for ch in target_bytes:
        target_freq[ch] = target_freq.get(ch, 0) + 1

    var required = len(target_freq)

    # ── sliding-window loop ──────────────────────────────────
    var window_freq = Dict[UInt8, Int]()
    var formed = 0
    var left: Int = 0
    var shortest_window_length: Int = source_length + 1
    var shortest_window_start: Int = 0

    for right in range(source_length):
        # Expand window by one character on the right.
        var ch = source_bytes[right]
        window_freq[ch] = window_freq.get(ch, 0) + 1

        if ch in target_freq and window_freq[ch] == target_freq[ch]:
            formed += 1

        # Contract from the left while the window is still valid.
        while formed == required:
            var current_window_length = right - left + 1
            if current_window_length < shortest_window_length:
                shortest_window_length = current_window_length
                shortest_window_start = left

            # Remove leftmost character from the window.
            var left_char = source_bytes[left]
            window_freq[left_char] = window_freq[left_char] - 1

            if left_char in target_freq and window_freq[left_char] < target_freq[left_char]:
                formed -= 1

            left += 1

    if shortest_window_length <= source_length:
        var sub_bytes = source_bytes[
            shortest_window_start : shortest_window_start + shortest_window_length
        ]
        return String(from_utf8=sub_bytes)

    return None


# ═══════════════════════════════════════════════════════════════
#  O(n³) brute-force reference (for correctness verification)
# ═══════════════════════════════════════════════════════════════

def min_window_bruteforce(s: String, t: String) raises -> Optional[String]:
    """Shortest substring of `s` containing all chars in `t` (brute force).

    Exhaustively checks every possible substring.  Used to verify the
    O(n) sliding-window implementation.
    """
    var source_bytes = s.as_bytes()
    var target_bytes = t.as_bytes()
    var source_length = len(source_bytes)
    var target_length = len(target_bytes)

    if source_length == 0 or target_length == 0 or source_length < target_length:
        return None

    var target_frequencies = Dict[UInt8, Int]()
    for ch in target_bytes:
        target_frequencies[ch] = target_frequencies.get(ch, 0) + 1

    var unique_target_char_count = len(target_frequencies)
    var shortest_window_length: Int = source_length + 1
    var shortest_window_start: Int = 0
    var window_frequencies = Dict[UInt8, Int]()

    for window_start in range(source_length - target_length + 1):
        if source_bytes[window_start] not in target_frequencies:
            continue

        for window_end in range(window_start + target_length - 1, source_length):
            if window_end == window_start + target_length - 1:
                window_frequencies.clear()
                for ch in source_bytes[window_start : window_end + 1]:
                    window_frequencies[ch] = window_frequencies.get(ch, 0) + 1
            else:
                var ch = source_bytes[window_end]
                window_frequencies[ch] = window_frequencies.get(ch, 0) + 1

            var satisfied_char_types = 0
            for item in target_frequencies.items():
                var letter = item.key
                var required_count = item.value
                if window_frequencies.get(letter, 0) >= required_count:
                    satisfied_char_types += 1

            if satisfied_char_types == unique_target_char_count:
                var current_window_length = window_end - window_start + 1
                if current_window_length < shortest_window_length:
                    shortest_window_length = current_window_length
                    shortest_window_start = window_start
                break

    if shortest_window_length <= source_length:
        var shortest_substring_bytes = source_bytes[
            shortest_window_start : shortest_window_start + shortest_window_length
        ]
        return String(from_utf8=shortest_substring_bytes)

    return None


# ═══════════════════════════════════════════════════════════════
#  Tests
# ═══════════════════════════════════════════════════════════════

def test_example_1() raises:
    assert_equal(min_window("ADOBECODEBANC", "ABC"), "BANC")


def test_example_2() raises:
    assert_equal(min_window("a", "a"), "a")


def test_example_3() raises:
    assert_equal(min_window("a", "aa"), None)


def test_contains_ain() raises:
    assert_equal(min_window("contains", "ain"), "ain")


def test_shortest_ntai() raises:
    assert_equal(min_window("ntai", "ain"), "ntai")


def test_negative_nums_matched() raises:
    assert_equal(min_window("xaybz", "ab"), "ayb")


def test_equal_length() raises:
    assert_equal(min_window("abc", "abc"), "abc")


def test_no_match() raises:
    assert_equal(min_window("a", "b"), None)


def test_duplicates_in_target() raises:
    assert_equal(min_window("aa", "aa"), "aa")
    assert_equal(min_window("aba", "aa"), "aba")


def test_window_at_end() raises:
    assert_equal(min_window("bac", "ac"), "ac")


def test_full_string_is_only_window() raises:
    assert_equal(min_window("abcdef", "az"), None)
    assert_equal(min_window("abcdef", "fed"), "def")


def test_bf_matches_sliding_window() raises:
    """Verify that both implementations agree on a diverse set of inputs."""
    var cases = List[String]()
    var targets = List[String]()
    cases.append("ADOBECODEBANC")
    targets.append("ABC")
    cases.append("figehaeci")
    targets.append("aei")
    cases.append("contains")
    targets.append("ain")
    cases.append("xaybz")
    targets.append("ab")
    cases.append("abc")
    targets.append("abc")
    cases.append("aa")
    targets.append("aa")
    cases.append("aba")
    targets.append("aa")
    cases.append("bac")
    targets.append("ac")
    cases.append("abcdef")
    targets.append("fed")

    for i in range(len(cases)):
        var sliding = min_window(cases[i], targets[i])
        var brute = min_window_bruteforce(cases[i], targets[i])
        assert_equal(sliding, brute, "Mismatch between implementations")


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
