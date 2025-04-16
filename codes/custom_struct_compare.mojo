from search_sorted_rotated_arr import find
from shapes import Rectangle


fn main():
    # Re
    r4 = Rectangle(4, 10)  # 40
    r5 = Rectangle(4, 12)  # 48
    r6 = Rectangle(5, 10)  # 50
    r7 = Rectangle(8, 8)  # 64
    r1 = Rectangle(3, 2)  # 6
    r2 = Rectangle(4, 4)  # 16
    r3 = Rectangle(4, 8)  # 32
    # Rectangles are sorted and rotated in the list
    items = List(r4, r5, r6, r7, r1, r2, r3)
    item_index = find(items, r2)
    debug_assert(item_index == 5, "Assertion failed")
