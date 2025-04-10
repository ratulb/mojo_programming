from gridv1 import Grid


fn run(owned grid: Grid) raises -> None:
    while True:
        print("Current mutation:\n\n")
        print(grid)
        print()
        print()
        if input("Enter 'q' to quit or press <Enter> to continue: ") == "q":
            break
        grid.mutate()


fn main() raises -> None:
    start = Grid.new(16, 16)
    run(start)
