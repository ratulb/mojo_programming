# We have no issues Referece1 calling Reference2 which also calls Reference1
from cyclic_reference_2 import Reference2


struct Reference1:
    fn __init__(out self):
        Reference2.print("Reference2 inside Reference1 constructor")

    @staticmethod
    fn print(s: String):
        print(s)


fn main():
    var ref1 = Reference1()
