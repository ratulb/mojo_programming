from gridv1 import Grid as GridV1
from gridv2 import Grid as GridV2
from utils import Variant
import random

alias Grid = Variant[GridV1, GridV2]


fn run(owned grid: Grid) raises -> None:
    var inner: GridV1
    if grid.isa[GridV1]():
        inner = grid[GridV1]
        print("Received a grid of type V1")
    else:
        inner = GridV1(grid[GridV2])
        print("Received a grid of type V2 - converted to V1")
    while True:
        print("Current mutation:\n\n")
        print(inner)
        print()
        print()
        if input("Enter 'q' to quit or press <Enter> to continue: ") == "q":
            break
        inner.mutate()


fn main() raises -> None:
    random.seed()
    var grid: Grid
    if random.random_ui64(0, 1):
        v1 = GridV1.new(16, 16)
        grid = Grid(v1)
    else:
        v2 = GridV2.new(None, 16, 16)
        grid = Grid(v2)
    run(grid^)
