# We have no issues Referece2 calling Reference1 which also calls Reference2

from cyclic_reference_1 import Reference1


struct Reference2:
    fn __init__(out self):
        Reference1.print("Reference1 inside Reference2 constructor")

    @staticmethod
    fn print(s: String):
        print(s)


fn main():
    var ref2 = Reference2()
