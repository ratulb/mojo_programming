
trait Shape(ComparableCollectionElement):
    def area(self) -> UInt:
        ...

@value
struct Rectangle(Shape):
    var length: UInt
    var width: UInt

    def area(self) -> UInt:
        return self.length * self.width

    def __lt__(self, other: Self) -> Bool:
        return self.area() < other.area()

    def __le__(self, other: Self) -> Bool:
        return self.area() <= other.area()

    def __eq__(self, other: Self) -> Bool:
        return self.area() == other.area()

    def __ne__(self, other: Self) -> Bool:
        return self.area() != other.area()

    def __gt__(self, other: Self) -> Bool:
        return self.area() > other.area()

    def __ge__(self, other: Self) -> Bool:
        return self.area() >= other.area()

