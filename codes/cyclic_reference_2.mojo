# We have no issues Referece2 calling Reference1 which also calls Reference2

from cyclic_reference_1 import Reference1


struct Reference2:
    def __init__(out self):
        Reference1.print("Reference1 inside Reference2 constructor")

    @staticmethod
    def print(s: String):
        print(s)


def main():
    var ref2 = Reference2()
