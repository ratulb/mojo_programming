import random
from collections import Optional
from memory import UnsafePointer, memcpy, memset_zero
from gridv1 import Grid as GridV1

struct Grid(Stringable, Writable):
    var data: UnsafePointer[UInt8]
    var rows: Int
    var cols: Int

    fn __init__(out self, rows: Int, cols: Int):
        self.rows = rows
        self.cols = cols
        self.data = UnsafePointer[UInt8].alloc(rows * cols)

    fn __init__(out self, source: GridV1):
        rows = len(source.data)
        cols = len(source.data[0])
        self = Self(rows, cols)
        for row in range(rows):
            for col in range(cols):
                value = UInt8(source[row, col])
                (self.data + row * cols + col)[] = value

    fn __copyinit__(out self, existing: Self):
        self.rows = existing.rows
        self.cols = existing.cols
        count = self.rows * self.cols
        self.data = UnsafePointer[UInt8].alloc(count)
        memcpy(dest=self.data, src=existing.data, count=count)

    fn __moveinit__(out self, owned existing: Self):
        self.data = existing.data
        self.rows = existing.rows
        self.cols = existing.cols
    
    fn __del__(owned self):
        self.data.free()    

    fn __str__(self) -> String:
        capacity = self.rows * self.cols
        if capacity == 0:
            return String()
        s = String(capacity=capacity)
        for row in range(self.rows):
            for col in range(self.cols):
                # if (self.data + row * self.cols + col)[] == 1:
                if self[row, col] == 1:
                    s += "*"  # Alive cell represented by '*'
                else:
                    s += " "  # Dead cell is blank
            if row != self.rows - 1:
                s += "\n"  # Line break between rows
        return s

    fn write_to[W: Writer](self, mut writer: W) -> None:
        writer.write(self.__str__())

    fn __getitem__(self, row: Int, col: Int) -> UInt8:
        return (self.data + row * self.cols + col)[]

    fn __setitem__(mut self, row: Int, col: Int, value: UInt8) -> None:
        (self.data + row * self.cols + col)[] = value

    @staticmethod
    fn new(seed: Optional[Int], rows: Int, cols: Int) -> Self:
        if seed:
            random.seed(seed.value())
        else:
            random.seed()
        grid = Self(rows, cols)
        random.randint(grid.data, rows * cols, 0, 1)
        return grid

    fn mutate(mut self) -> None:
        rows = self.rows
        cols = self.cols
        for row in range(rows):
            above = (row - 1) % rows
            below = (row + 1) % rows
            for col in range(cols):
                left = (col - 1) % cols
                right = (col + 1) % cols
                alive_neighbours = (
                    self[above, left]
                    + self[above, col]
                    + self[above, right]
                    + self[row, right]
                    + self[below, right]
                    + self[below, col]
                    + self[below, left]
                    + self[row, left]
                )
                if self[row, col] == 1:
                    if alive_neighbours < 2:
                        self[row, col] = 0
                    if alive_neighbours == 2 or alive_neighbours == 3:
                        continue
                    if alive_neighbours > 3:
                        self[row, col] = 0
                else:
                    if alive_neighbours == 3:
                        self[row, col] = 1


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
    grid_1 = GridV1.new(16, 16)
    # run(grid_1)
    print(grid_1)
    print("Implicit conversion\n\n")
    grid_2 = Grid(grid_1)
    print(grid_2)
