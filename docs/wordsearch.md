### Word Search
### Check if a word can be formed in a grid by sequentially adjacent (non-repeating) horizontal or vertical letters.

```python

from collections import Set

alias SString = List[StaticString]
alias SStrings = List[SString]


fn present(board: SStrings, word: StaticString) raises -> Bool:
    if len(board) == 0:
        return False
    rows, cols = len(board), len(board[0])
    visited = Set[String]()
    for row in range(rows):
        for col in range(cols):
            if trace(rows, cols, board, word, 0, row, col, visited):
                return True
    return False


fn trace(
    rows: UInt,
    cols: UInt,
    board: SStrings,
    word: StaticString,
    idx: UInt,
    row: UInt,
    col: UInt,
    mut visited: Set[String],
) raises -> Bool:
    if len(word) == idx:
        return True
    cell = String(row) + String(col)
    if (
        row < 0
        or row >= rows
        or col < 0
        or col >= cols
        or board[row][col] != word[idx]
        or cell in visited
    ):
        return False
    visited.add(cell)
    exists = (
        trace(rows, cols, board, word, idx + 1, row + 1, col, visited)
        or trace(rows, cols, board, word, idx + 1, row - 1, col, visited)
        or trace(rows, cols, board, word, idx + 1, row, col + 1, visited)
        or trace(rows, cols, board, word, idx + 1, row, col - 1, visited)
    )
    visited.remove(cell)
    return exists


from testing import assert_true, assert_false


fn main() raises:
    board = SStrings(
        SString("A", "B", "C", "E"),
        SString("S", "F", "C", "S"),
        SString("A", "D", "E", "E"),
    )
    word1 = "ABCB"
    result = present(board, word1)
    assert_false(result, "Assertion failed")
    board = SStrings(
        SString("A", "B", "C", "E"),
        SString("S", "F", "C", "S"),
        SString("A", "D", "E", "E"),
    )
    word2 = "SEE"
    result = present(board, word2)
    assert_true(result, "Assertion failed")
    board = SStrings(
        SString("A", "B", "C", "E"),
        SString("S", "F", "C", "S"),
        SString("A", "D", "E", "E"),
    )
    word3 = "ABCCED"
    result = present(board, word3)
    assert_true(result, "Assertion failed")

```


[Source](https://github.com/ratulb/mojo_programming/blob/main/codes/wordsearch.mojo)