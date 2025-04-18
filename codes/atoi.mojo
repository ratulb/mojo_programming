### String to Integer (atoi)
### Implement the atoi(string s) function, which converts a string to a signed integer.


fn atoi(s: String) raises -> Int:
    # Return 0 for an empty string (edge case)
    if len(s) == 0:
        return 0

    buffer = String()  # Buffer to collect valid characters forming the number
    digits = String("0123456789")  # Valid digit characters
    idx = 0  # Index for scanning the string
    prelude = True  # Indicates we're in the whitespace/prefix-skipping phase

    while idx < len(s):
        # Skip leading whitespaces
        while prelude and idx < len(s) and (s[idx] == " "):
            idx += 1
            continue

        # If we have skipped whitespaces, check for sign or digit
        if prelude and idx < len(s):
            # If current char is '+' or '-' or a digit, add it to buffer
            if s[idx] == "-" or s[idx] == "+" or s[idx] in digits:
                buffer.__iadd__(s[idx])
                idx += 1
                prelude = False  # Exit prelude phase after processing sign or first digit
                continue
            else:
                # Invalid character before number starts; exit parsing
                break

        # If we encounter a non-digit (excluding whitespace in middle), break
        if s[idx] != " " and s[idx] not in digits:
            break

        # If it's a digit, add to buffer
        if s[idx] in digits:
            buffer.__iadd__(s[idx])
        idx += 1

    # Now buffer contains something like "-123", "456", "+789", etc.
    number, factor = 0, 1

    # Convert from left to right (excluding the first char which could be a sign)
    for idx in range(len(buffer) - 1, 0, -1):
        number = number + Int(buffer[idx]) * factor
        factor *= 10

    # Handle the first character (either a sign or a digit)
    number = (
        -1 * number if buffer[0] == "-" else number + Int(buffer[0]) * factor
    ) if len(buffer) > 1 else number

    return number


from testing import assert_equal


fn main() raises:
    s = "   -           13   37    c0d3"
    number = atoi(s)
    print(number)

    s1 = "13   37    c0d3"
    number = atoi(s1)
    print(number)

    s2 = "1337c0d3"
    number = atoi(s2)
    print(number)

    s3 = "   -042"
    number = atoi(s3)
    print(number)

    s4 = "42"
    number = atoi(s4)
    print(number)

    s5 = "0-1"
    number = atoi(s5)
    print(number)

    s6 = "words and 987"
    number = atoi(s6)
    print(number)

    s7 = "    words and 987"
    number = atoi(s7)
    print(number)
    print(Int.MAX)
    print(Int.MAX+1)
