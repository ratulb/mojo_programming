### Find All Anagrams in a String
### Return all start indices of anagrams of string p in string s.

from collections import Dict


fn find_anagrams(s: String, p: String) -> List[Int]:
    if len(s) < len(p):
        return List[Int]()
    pdict = Dict[String, Int]()
    sdict = Dict[String, Int]()
    for i in range(len(p)):
        pdict[p[i]] = 1 + pdict.get(p[i], 0)
        sdict[s[i]] = 1 + sdict.get(s[i], 0)
    result = List(0) if equals(pdict, sdict) else List[Int]()
    left, right = 0, len(p)
    while right < len(s):
        sdict[s[right]] = 1 + sdict.get(s[right], 0)
        sdict[s[left]] = sdict.get(s[left], 1) - 1
        if sdict.get(s[left]) and sdict.get(s[left]).value() == 0:
            try:
                _ = sdict.pop(s[left])
            except e:
                print(e)
        right += 1
        left += 1
        if equals(pdict, sdict):
            result.append(left)
    return result


fn equals(read d1: Dict[String, Int], read d2: Dict[String, Int]) -> Bool:
    if len(d1) != len(d2):
        return False
    for each in d1.items():
        try:
            if each[].value != d2[each[].key]:
                return False
        except e:
            return False
    return True


from testing import assert_equal


fn main() raises:
    var s: String = "abc"
    var p: String = "abc"
    result = find_anagrams(s, p)
    assert_equal(result, List(0), "Assertion failed")

    s = "cba"
    p = "abc"
    result = find_anagrams(s, p)
    assert_equal(result, List(0), "Assertion failed")

    s = "cbaa"
    p = "abc"
    result = find_anagrams(s, p)
    assert_equal(result, List(0), "Assertion failed")

    s = "cbaacb"
    p = "abc"
    result = find_anagrams(s, p)
    assert_equal(result, List(0, 3), "Assertion failed")

    s = "cbaebabacd"
    p = "abc"
    result = find_anagrams(s, p)
    assert_equal(result, List(0, 6), "Assertion failed")

    s = "abab"
    p = "ab"
    result = find_anagrams(s, p)
    assert_equal(result, List(0, 1, 2), "Assertion failed")
