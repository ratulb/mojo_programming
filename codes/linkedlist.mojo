### Generic singnly link list
### A singly linked list with parametric polymorphism.
### Current supports adding multiple elements at one go via the `append` method

from memory import Pointer, UnsafePointer

alias ElementType = CollectionElement

@value
struct Node[
    T: ElementType,
]:
    alias NextNode = UnsafePointer[Self]
    var value: T
    var next: Self.NextNode

    fn __init__(
        out self,
        owned value: T,
    ):
        self.value = value
        self.next = Self.NextNode()

    fn __init__(
        out self,
        owned value: T,
        next: Optional[Self.NextNode],
    ):
        self.value = value^
        self.next = next.value() if next else Self.NextNode()

    fn __bool__(self) -> Bool:
        return True

    fn __str__[
        ElementType: WritableCollectionElement
    ](self: Node[ElementType]) -> String:
        return String.write(self.value)


struct LinkedList[T: ElementType]:
    var head: Optional[Node[T]]
    var len: UInt

    fn __init__(out self):
        self.head = None
        self.len = 0

    fn __init__(out self, *elems: T):
        self = Self()
        self.append(elems)

    fn append(mut self, *elems: T):
        self.append(elems)

    fn append(mut self, elems: VariadicListMem[T]):
        if len(elems) == 0:
            return
        next = 0
        var current: UnsafePointer[Node[T]]
        if self.head is None:
            self.head = Optional(Node(elems[0]))
            current = UnsafePointer(to=self.head.value())
            next = 1
            self.len += 1
        else:
            curr = UnsafePointer(to=self.head.value())
            while curr and curr[].next:
                curr = curr[].next
            current = curr
        for i in range(next, len(elems)):
            node = Node(elems[i])
            current[].next = UnsafePointer[Node[T]].alloc(1)
            current[].next.init_pointee_move(node)
            current = current[].next
            self.len += 1

    fn __str__[
        ElementType: WritableCollectionElement
    ](self: LinkedList[ElementType]) -> String:
        if self.len == 0:
            return String("[]")
        else:
            s = String("[")
            current = self.head.value()
            s.write(current.value)
            for i in range(1, self.len):
                next = current.next[]
                if i <= self.len - 1:
                    s.write(", ")
                s.write(next.value)
                current = next
            s.write("]")
            return s

fn main():
    linkedlist = LinkedList[Int]()
    print(linkedlist.__str__())

    linkedlist = LinkedList(1)
    print(linkedlist.__str__())

    linkedlist = LinkedList(1, 2, 3)
    print(linkedlist.__str__())

    linkedlist.append(4, 5, 6)
    print(linkedlist.len)
    print(linkedlist.__str__())



