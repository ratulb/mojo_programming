import random


@value
struct Grid(Stringable, Writable):
    var data: List[List[Int]]

    fn __init__(out self, data: List[List[Int]]):
        self.data = data

    fn row_count(self) -> Int:
        if self.data:
            return len(self.data)
        else:
            return 0

    fn col_count(self) -> Int:
        if self.data[0]:
            return len(self.data[0])
        else:
            return 0

    fn __str__(self) -> String:
        capacity = self.row_count() * self.col_count()
        if capacity == 0:
            return String()
        s = String(capacity=capacity)
        row_index = 0
        for row in self.data:
            for col in row[]:
                if col[] == 1:
                    s += "*"
                else:
                    s += " "
            if row_index != self.row_count() - 1:
                s += "\n"
            row_index += 1
        return s

    fn write_to[W: Writer](self, mut writer: W) -> None:
        writer.write(self.__str__())

    fn __getitem__(self, row: Int, col: Int) -> Int:
        return self.data[row][col]

    fn __setitem__(mut self, row: Int, col: Int, value: Int) -> None:
        self.data[row][col] = value

    @staticmethod
    fn new(rows: Int, cols: Int) -> Self:
        random.seed()
        data = List[List[Int]](capacity=rows)
        for row in range(rows):
            record = List[Int](capacity=cols)
            for col in range(cols):
                record.append(Int(random.random_si64(0, 1)))
            data.append(record)
        return Self(data)
