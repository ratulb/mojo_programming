import random
from gridv2 import Grid as GridV2


# Grid is a 2D structure holding cell states (0: dead, 1: alive)
# It supports string conversion, output writing, and cell access/update
@value
struct Grid(Stringable, Writable):
    var data: List[List[Int, True]]  # 2D grid of integers (1 = alive, 0 = dead)

    # Constructor to initialize the grid with given data
    fn __init__(out self, data: List[List[Int, True]]):
        self.data = data

    @implicit
    fn __init__(out self, source: GridV2):
        data = source.data
        rows = source.rows
        cols = source.cols
        grid = List[List[Int, True]]()
        for row in range(rows):
            curr_row = List[Int, True]()
            for col in range(cols):
                curr_row.append(Int((data + (row * cols + col))[]))
            grid.append(curr_row)
        self.data = grid^

    # Get the number of rows in the grid
    fn row_count(self) -> Int:
        if self.data:
            return len(self.data)
        else:
            return 0

    # Get the number of columns in the grid
    fn col_count(self) -> Int:
        if self.data[0]:
            return len(self.data[0])
        else:
            return 0

    # Convert the grid to a string for pretty-printing
    fn __str__(self) -> String:
        capacity = self.row_count() * self.col_count()
        if capacity == 0:
            return String()
        s = String(capacity=capacity)
        row_index = 0
        for row in self.data:
            for col in row[]:
                if col[] == 1:
                    s += "*"  # Alive cell represented by '*'
                else:
                    s += " "  # Dead cell is blank
            if row_index != self.row_count() - 1:
                s += "\n"  # Line break between rows
            row_index += 1
        return s

    # Allow writing the grid to any output writer
    fn write_to[W: Writer](self, mut writer: W) -> None:
        writer.write(self.__str__())

    # Access cell at (row, col)
    fn __getitem__(self, row: Int, col: Int) -> Int:
        return self.data[row][col]

    # Update cell at (row, col)
    fn __setitem__(mut self, row: Int, col: Int, value: Int) -> None:
        self.data[row][col] = value

    # Static method to create a random grid with specified size
    @staticmethod
    fn new(rows: Int, cols: Int) -> Self:
        random.seed()
        data = List[List[Int, True]](capacity=rows)
        for row in range(rows):
            record = List[Int, True](capacity=cols)
            for col in range(cols):
                # Initialize each cell randomly to 0 or 1
                record.append(Int(random.random_si64(0, 1)))
            data.append(record)
        return Self(data)

    # Perform one step of mutation (Game of Life rules)
    fn mutate(mut self):
        rows = self.row_count()
        cols = self.col_count()
        for row in range(rows):
            above = (row - 1) % rows
            below = (row + 1) % rows
            for col in range(cols):
                left = (col - 1) % cols
                right = (col + 1) % cols

                # Count live neighbors using 8-connected grid
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

                # Apply Conway's Game of Life rules:
                # Rule 1 & 2: Any live cell with 2 or 3 live neighbors survives
                if self[row, col] == 1 and (
                    alive_neighbours == 2 or alive_neighbours == 3
                ):
                    continue  # Keep alive

                # Rule 3: All other live cells die
                else:
                    self[row, col] = 0

                # Rule 4: Any dead cell with exactly 3 live neighbors becomes alive
                if self[row, col] == 0 and alive_neighbours == 3:
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
    grid_2 = GridV2.new(42, 16, 16)
    #run(grid_2)
    print(grid_2)
    print("Implicit conversion\n\n")
    grid_1 = Grid(grid_2)
    print(grid_1)
