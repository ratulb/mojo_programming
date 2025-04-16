
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

