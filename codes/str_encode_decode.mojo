"""
Encode and Decode Strings.

Design an algorithm to encode a list of ASCII strings into a single
string and decode it back without loss.  The challenge is to handle
strings that may contain delimiters, digits, or any arbitrary content.

**Length-prefix approach** — format: `<length>#<string>` per element.

Encoding:
  1. For each string, compute its byte length.
  2. Append the length (as a decimal number), then `#`, then the string.

Decoding:
  1. Scan for `#` to locate the length prefix.
  2. Parse the digits before `#` as an integer — this is the byte length
     of the following string.
  3. Extract exactly that many bytes after `#` and add to the result.
  4. Repeat until the entire encoded string is consumed.

This scheme is unambiguous because the length prefix tells the decoder
exactly where each string ends, regardless of what characters it
contains.

Example:

    encode(["hello", "world"])   →  "5#hello5#world"
    decode("5#hello5#world")     →  ["hello", "world"]
"""

from std.collections.string import Codepoint
from std.testing import assert_equal, TestSuite


# ═══════════════════════════════════════════════════════════════
#  Encoder
# ═══════════════════════════════════════════════════════════════

def encode(strs: List[String]) -> String:
    """Encode a list of strings into a single length-prefixed string.

    For each input string, appends `byte_length` + `"#"` + the string
    itself.  The lengths are written as decimal ASCII digits so that
    the decoder can always locate the next boundary via the `#` marker.
    """
    var result = ""
    for s in strs:
        result += String(s.byte_length()) + "#" + s
    return result^


# ═══════════════════════════════════════════════════════════════
#  Decoder
# ═══════════════════════════════════════════════════════════════

def decode(s: String) raises -> List[String]:
    """Decode a length-prefixed string back into a list of strings.

    1. Walk the byte span to find each `#` separator.
    2. Read the digits before `#` as the byte-length of the string.
    3. Slice exactly that many bytes after `#` and reconstruct the
       original string.
    """
    var result = List[String]()
    var i = 0
    comptime ascii_hash = UInt8(Int(Codepoint.ord("#")))
    var bytes = s.as_bytes()

    while i < len(bytes):
        # Find the `#` separator — everything between i and j is the
        # decimal length prefix.
        var j = i
        while j < len(bytes) and bytes[j] != ascii_hash:
            j += 1

        # Parse the length digits as an integer.
        var length_digits = bytes[i:j]
        var str_length = Int(String(from_utf8=length_digits))

        # The string data starts right after `#` and occupies exactly
        # `str_length` bytes.
        var str_start = j + 1
        result.append(String(from_utf8=bytes[str_start : str_start + str_length]))

        # Advance past the string data to the start of the next entry.
        i = str_start + str_length

    return result^


# ═══════════════════════════════════════════════════════════════
#  Tests
# ═══════════════════════════════════════════════════════════════

def test_roundtrip_simple() raises:
    var original: List[String] = ["hello", "world"]
    assert_equal(decode(encode(original)), original)


def test_roundtrip_single_string() raises:
    var original: List[String] = ["def"]
    assert_equal(decode(encode(original)), original)


def test_roundtrip_empty_list() raises:
    var original = List[String]()
    assert_equal(decode(encode(original)), original)


def test_roundtrip_empty_string() raises:
    var original: List[String] = [""]
    assert_equal(decode(encode(original)), original)


def test_roundtrip_multiple_empty() raises:
    var original: List[String] = ["", "", ""]
    assert_equal(decode(encode(original)), original)


def test_roundtrip_with_delimiter() raises:
    var original: List[String] = ["a#b", "c#d"]
    assert_equal(decode(encode(original)), original)


def test_roundtrip_with_numbers() raises:
    var original: List[String] = ["123", "456", "789"]
    assert_equal(decode(encode(original)), original)


def test_roundtrip_mixed() raises:
    var original: List[String] = ["def", "main()", "raises"]
    assert_equal(decode(encode(original)), original)


def test_roundtrip_special_chars() raises:
    var original: List[String] = ["!@#$%", "  spaces  ", "\t\n"]
    assert_equal(decode(encode(original)), original)


def test_roundtrip_long_string() raises:
    var original: List[String] = [
        "a" * 100,
        "b" * 200,
    ]
    assert_equal(decode(encode(original)), original)


def test_roundtrip_all_ascii_printable() raises:
    var all_chars = ""
    for i in range(32, 127):  # printable ASCII range
        all_chars += String(chr(i))
    var original: List[String] = [all_chars]
    assert_equal(decode(encode(original)), original)


def test_roundtrip_preserves_order() raises:
    var original: List[String] = [
        "first", "second", "third", "fourth", "fifth",
    ]
    var decoded = decode(encode(original))
    assert_equal(len(decoded), 5)
    for i in range(5):
        assert_equal(decoded[i], original[i])


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
