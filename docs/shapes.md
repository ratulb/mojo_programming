### Below we define a custome[trait](https://docs.modular.com/mojo/manual/traits) called Shape which extends [ComparableCollectionElement](https://docs.modular.com/mojo/stdlib/builtin/value/ComparableCollectionElement). The custom trait adds a method called `area`. 
### We define a [struct] (https://docs.modular.com/mojo/manual/structs) called `Rectangle` which implements all the that `Shape` declares and the ones that it iherits by extending `ComparableCollectionElement`.

### `ComparableCollectionElement` extends [CollectionElement](https://docs.modular.com/mojo/stdlib/builtin/value/CollectionElement) and hence `Rectangle` is supposed to implement methods inherited from `CollectionElement` as well. But we get free implementation of those methods by decorating the `Rectangle`struct with the [@value](https://docs.modular.com/mojo/manual/decorators/value/) decorator.

### Define a custom [trait](https://docs.modular.com/mojo/manual/traits) named `Shape`, which extends 
### [ComparableCollectionElement](https://docs.modular.com/mojo/stdlib/builtin/value/ComparableCollectionElement). 
### The `Shape` trait introduces a single abstract method: `area`.

### Next, define a [struct](https://docs.modular.com/mojo/manual/structs) called `Rectangle` that implements 
### the `Shape` trait, as well as all methods required by `ComparableCollectionElement`, which is inherited via `Shape`.

### Since `ComparableCollectionElement` itself extends 
### [CollectionElement](https://docs.modular.com/mojo/stdlib/builtin/value/CollectionElement), the `Rectangle` 
### struct is also expected to implement the corresponding methods. However, by annotating `Rectangle` with 
### the [@value](https://docs.modular.com/mojo/manual/decorators/value/) decorator, implementations of 
### these collection-related methods are automatically provided by the Mojo standard library.


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

