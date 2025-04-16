### Define a custom [trait](https://docs.modular.com/mojo/manual/traits) named `Shape`, which extends [ComparableCollectionElement](https://docs.modular.com/mojo/stdlib/builtin/value/ComparableCollectionElement). 

### The `Shape` trait introduces a single abstract method: `area`.

### Next, define a [struct](https://docs.modular.com/mojo/manual/structs) called `Rectangle` that implements the `Shape` trait, as well as all methods required by [ComparableCollectionElement](https://docs.modular.com/mojo/stdlib/builtin/value/ComparableCollectionElement) which is inherited by `Shape`.

### Since [ComparableCollectionElement](https://docs.modular.com/mojo/stdlib/builtin/value/ComparableCollectionElement) itself extends [CollectionElement](https://docs.modular.com/mojo/stdlib/builtin/value/CollectionElement), the `Rectangle` struct is also expected to implement the corresponding methods. However, by annotating `Rectangle` with the [@value](https://docs.modular.com/mojo/manual/decorators/value/) decorator, implementations of these collection-related methods are automatically provided by the Mojo compiler by default.

```python

trait Shape(ComparableCollectionElement):
    fn area(self) -> UInt:
        ...

@value
struct Rectangle(Shape):
    var length: UInt
    var width: UInt

    fn area(self) -> UInt:
        return self.length * self.width

    fn __lt__(self, other: Self) -> Bool:
        return self.area() < other.area()

    fn __le__(self, other: Self) -> Bool:
        return self.area() <= other.area()

    fn __eq__(self, other: Self) -> Bool:
        return self.area() == other.area()

    fn __ne__(self, other: Self) -> Bool:
        return self.area() != other.area()

    fn __gt__(self, other: Self) -> Bool:
        return self.area() > other.area()

    fn __ge__(self, other: Self) -> Bool:
        return self.area() >= other.area()

```
## [Driver code](https://github.com/ratulb/mojo_programming/blob/main/codes/custom_struct_compare.mojo)
```python

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

```
## [Find implementation]()
