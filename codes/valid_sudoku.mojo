"""
Valid Sudoku.

Determine if a 9 x 9 Sudoku board is valid.  Only the filled cells need
to be validated according to three rules:

1. Each row must contain the digits 1–9 without repetition.
2. Each column must contain the digits 1–9 without repetition.
3. Each of the nine 3 x 3 sub-boxes must contain the digits 1–9 without
   repetition.

Note: a valid board is not necessarily solvable — only filled cells are
checked.

Algorithm — O(81) = O(1) time and space:

  Maintain three dictionaries mapping coordinates to a `Set` of seen
  digits — one for rows (indexed by row number), one for columns
  (indexed by column number), and one for 3x3 sub-boxes (keyed by
  `(row // 3, col // 3)`).  For each cell: if it contains a digit,
  pop the corresponding sets, check for duplicates, add the digit,
  and store the set back.  If any duplicate is found the board is
  invalid.

Example:

    valid_sudoku([
      ["5","3",".",".","7",".",".",".","."],
      ["6",".",".","1","9","5",".",".","."],
      [".","9","8",".",".",".",".","6","."],
      ["8",".",".",".","6",".",".",".","3"],
      ["4",".",".","8",".","3",".",".","1"],
      ["7",".",".",".","2",".",".",".","6"],
      [".","6",".",".",".",".","2","8","."],
      [".",".",".","4","1","9",".",".","5"],
      [".",".",".",".","8",".",".","7","9"],
    ])  →  true

    (Swapping the top-left "5" for "8" makes the board invalid because
    column 0 and the top-left sub-box would both contain duplicate 8s.)
"""

from std.collections import Set
from std.testing import assert_false, assert_true, TestSuite


# ═══════════════════════════════════════════════════════════════
#  Validator
# ═══════════════════════════════════════════════════════════════


def valid_sudoku(board: List[List[String]]) -> Bool:
    """Check whether a 9x9 Sudoku board obeys the three validity rules.

    One pass over the board: for each filled cell, the digit is checked
    against the row-set, column-set, and sub-box-set for its position.
    On first sight of a duplicate the function returns `False`.
    """
    # Defensive shape check (a proper caller would always pass 9×9).
    if len(board) != 9:
        return False
    for r in range(9):
        if len(board[r]) != 9:
            return False

    # Three dictionaries tracking digits seen per row, column, and
    # 3×3 sub-box.  Each value is a Set that is "popped" (removed &
    # returned), mutated, and then stored back.
    var rows = Dict[Int, Set[String]]()
    var cols = Dict[Int, Set[String]]()
    var squares = Dict[Tuple[Int, Int], Set[String]]()

    for r in range(9):
        for c in range(9):
            var value = board[r][c]
            if value == ".":
                continue

            # Pop the three sets for the current position (or get a
            # fresh empty set if this is the first cell in that group).
            var row = rows.pop(r, Set[String]())
            var col = cols.pop(c, Set[String]())
            var square = squares.pop((r // 3, c // 3), Set[String]())

            # Duplicate in any of the three groups → invalid.
            if value in row or value in col or value in square:
                return False

            row.add(value)
            col.add(value)
            square.add(value)

            # Store the mutated sets back into their dictionaries.
            rows[r] = row^
            cols[c] = col^
            squares[(r // 3, c // 3)] = square^

    return True


# ═══════════════════════════════════════════════════════════════
#  Tests
# ═══════════════════════════════════════════════════════════════

# ── valid boards ────────────────────────────────────────────


def test_valid_example() raises:
    var board: List[List[String]] = [
        ["5", "3", ".", ".", "7", ".", ".", ".", "."],
        ["6", ".", ".", "1", "9", "5", ".", ".", "."],
        [".", "9", "8", ".", ".", ".", ".", "6", "."],
        ["8", ".", ".", ".", "6", ".", ".", ".", "3"],
        ["4", ".", ".", "8", ".", "3", ".", ".", "1"],
        ["7", ".", ".", ".", "2", ".", ".", ".", "6"],
        [".", "6", ".", ".", ".", ".", "2", "8", "."],
        [".", ".", ".", "4", "1", "9", ".", ".", "5"],
        [".", ".", ".", ".", "8", ".", ".", "7", "9"],
    ]
    assert_true(valid_sudoku(board^))


def test_empty_board() raises:
    var board: List[List[String]] = [
        [".", ".", ".", ".", ".", ".", ".", ".", "."],
        [".", ".", ".", ".", ".", ".", ".", ".", "."],
        [".", ".", ".", ".", ".", ".", ".", ".", "."],
        [".", ".", ".", ".", ".", ".", ".", ".", "."],
        [".", ".", ".", ".", ".", ".", ".", ".", "."],
        [".", ".", ".", ".", ".", ".", ".", ".", "."],
        [".", ".", ".", ".", ".", ".", ".", ".", "."],
        [".", ".", ".", ".", ".", ".", ".", ".", "."],
        [".", ".", ".", ".", ".", ".", ".", ".", "."],
    ]
    assert_true(valid_sudoku(board^))


def test_full_valid_board() raises:
    var board: List[List[String]] = [
        ["5", "3", "4", "6", "7", "8", "9", "1", "2"],
        ["6", "7", "2", "1", "9", "5", "3", "4", "8"],
        ["1", "9", "8", "3", "4", "2", "5", "6", "7"],
        ["8", "5", "9", "7", "6", "1", "4", "2", "3"],
        ["4", "2", "6", "8", "5", "3", "7", "9", "1"],
        ["7", "1", "3", "9", "2", "4", "8", "5", "6"],
        ["9", "6", "1", "5", "3", "7", "2", "8", "4"],
        ["2", "8", "7", "4", "1", "9", "6", "3", "5"],
        ["3", "4", "5", "2", "8", "6", "1", "7", "9"],
    ]
    assert_true(valid_sudoku(board^))


# ── invalid boards ──────────────────────────────────────────


def test_invalid_duplicate_in_row() raises:
    var board: List[List[String]] = [
        ["8", "3", ".", ".", "7", ".", ".", ".", "."],
        ["6", ".", ".", "1", "9", "5", ".", ".", "."],
        [".", "9", "8", ".", ".", ".", ".", "6", "."],
        ["8", ".", ".", ".", "6", ".", ".", ".", "3"],
        ["4", ".", ".", "8", ".", "3", ".", ".", "1"],
        ["7", ".", ".", ".", "2", ".", ".", ".", "6"],
        [".", "6", ".", ".", ".", ".", "2", "8", "."],
        [".", ".", ".", "4", "1", "9", ".", ".", "5"],
        [".", ".", ".", ".", "8", ".", ".", "7", "9"],
    ]
    # Two 8s in column 0 (rows 0 and 3) and in the top-left sub-box.
    assert_false(valid_sudoku(board^))


def test_invalid_duplicate_in_column() raises:
    var board: List[List[String]] = [
        ["5", "3", ".", ".", "7", ".", ".", ".", "."],
        ["6", ".", ".", "1", "9", "5", ".", ".", "."],
        [".", "9", "8", ".", ".", ".", ".", "6", "."],
        ["8", ".", ".", ".", "6", ".", ".", ".", "3"],
        ["4", ".", ".", "8", ".", "3", ".", ".", "1"],
        ["7", ".", ".", ".", "2", ".", ".", ".", "6"],
        [".", "6", ".", ".", ".", ".", "2", "8", "."],
        [".", ".", ".", "4", "1", "9", ".", ".", "5"],
        ["5", ".", ".", ".", "8", ".", ".", "7", "9"],
    ]
    # Two 5s in column 0 (rows 0 and 8).
    assert_false(valid_sudoku(board^))


def test_invalid_duplicate_in_subbox() raises:
    var board: List[List[String]] = [
        ["5", "3", ".", ".", "7", ".", ".", ".", "."],
        ["6", ".", ".", "1", "9", "5", ".", ".", "."],
        [".", "9", "8", ".", ".", ".", ".", "6", "."],
        ["8", ".", ".", ".", "6", ".", ".", ".", "3"],
        ["4", ".", ".", "8", ".", "3", ".", ".", "1"],
        ["7", ".", ".", ".", "2", ".", ".", ".", "6"],
        [".", "6", ".", ".", ".", ".", "2", "8", "."],
        [".", ".", ".", "4", "1", "9", ".", ".", "5"],
        [".", ".", ".", ".", "8", ".", ".", "7", "9"],
    ]
    # Keep board from example 1 but insert duplicate 3 in top-left sub-box.
    board[0][1] = String("3")  # already 3 at (1,2), sub-box (0,0)
    board[1][2] = String("3")
    assert_false(valid_sudoku(board^))


def test_invalid_wrong_dimensions() raises:
    var board = List[List[String]](capacity=3)
    board.append(["1", "2", "3"])
    board.append(["4", "5", "6"])
    board.append(["7", "8", "9"])
    assert_false(valid_sudoku(board^))


def test_invalid_all_same_digit() raises:
    var board: List[List[String]] = [
        ["1", "1", ".", ".", ".", ".", ".", ".", "."],
        [".", ".", ".", ".", ".", ".", ".", ".", "."],
        [".", ".", ".", ".", ".", ".", ".", ".", "."],
        [".", ".", ".", ".", ".", ".", ".", ".", "."],
        [".", ".", ".", ".", ".", ".", ".", ".", "."],
        [".", ".", ".", ".", ".", ".", ".", ".", "."],
        [".", ".", ".", ".", ".", ".", ".", ".", "."],
        [".", ".", ".", ".", ".", ".", ".", ".", "."],
        [".", ".", ".", ".", ".", ".", ".", ".", "."],
    ]
    assert_false(valid_sudoku(board^))


def test_invalid_digit_in_last_cell() raises:
    """A duplicate placed in the very last cell of a row/col/box."""
    var board: List[List[String]] = [
        ["1", "2", "3", "4", "5", "6", "7", "8", "9"],
        ["4", "5", "6", "7", "8", "9", "1", "2", "3"],
        ["7", "8", "9", "1", "2", "3", "4", "5", "6"],
        ["2", "3", "4", "5", "6", "7", "8", "9", "1"],
        ["5", "6", "7", "8", "9", "1", "2", "3", "4"],
        ["8", "9", "1", "2", "3", "4", "5", "6", "7"],
        ["3", "4", "5", "6", "7", "8", "9", "1", "2"],
        ["6", "7", "8", "9", "1", "2", "3", "4", "5"],
        ["9", "1", "2", "3", "4", "5", "6", "7", "1"],
    ]
    # Last cell duplicates 1 from the start of its row, column, and sub-box.
    assert_false(valid_sudoku(board^))


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
