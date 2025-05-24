### Dumb matrix multiplication
### Use one one GPU thread for each column of the output matrix

from gpu.host import DeviceContext, HostBuffer
from gpu import thread_idx, block_idx, block_dim
import random
from layout import Layout, LayoutTensor
from memory import UnsafePointer, memcpy
from python import Python, PythonObject
from testing import assert_true

alias ROWS_A = 64
alias COLS_A = 16
alias ROWS_B = 16
alias COLS_B = 8
alias ROWS_C = ROWS_A
alias COLS_C = COLS_B

alias MATRIX_MIN_ELEM = -5.0
alias MATRIX_MAX_ELEM = 5.0

alias dtype = DType.float32
# Num threads per block
alias THREADS = (5, 5)
# Total numbers blocks in the grid
alias BLOCKS = (
    (COLS_C + THREADS[0] - 1) // THREADS[0],
    (ROWS_C + THREADS[1] - 1) // THREADS[1],
)

alias layout_a = Layout.row_major(ROWS_A, COLS_A)
alias layout_b = Layout.row_major(ROWS_B, COLS_B)
alias layout_c = Layout.row_major(ROWS_C, COLS_C)


alias MatrixA = LayoutTensor[dtype, layout_a, MutableAnyOrigin]
alias MatrixB = LayoutTensor[dtype, layout_b, MutableAnyOrigin]
alias MatrixC = LayoutTensor[dtype, layout_c, MutableAnyOrigin]


fn matmul_thread_per_output_cell[
    a: Layout, b: Layout, c: Layout
](A: MatrixA, B: MatrixB, C: MatrixC,):
    var i = block_idx.y * block_dim.y + thread_idx.y  # Rows
    var j = block_idx.x * block_dim.x + thread_idx.x  # Colums

    if i < ROWS_C and j < COLS_C:
        for k in range(ROWS_B):
            C[i, j] += A[i, k] * B[k, j]


# Initialize the matrix buffer with values in the range 0 to 100
fn fill_buffer(buffer: HostBuffer[dtype]):
    # Randomize
    random.seed()
    for i in range(len(buffer)):
        buffer[i] = random.random_float64(
            MATRIX_MIN_ELEM, MATRIX_MAX_ELEM
        ).cast[dtype]()[0]


fn main():
    try:
        ctx = DeviceContext()

        buffer_a = ctx.enqueue_create_buffer[dtype](
            ROWS_A * COLS_A
        ).enqueue_fill(0.0)
        buffer_b = ctx.enqueue_create_buffer[dtype](
            ROWS_B * COLS_B
        ).enqueue_fill(0.0)
        buffer_c = ctx.enqueue_create_buffer[dtype](
            ROWS_C * COLS_C
        ).enqueue_fill(0.0)

        with buffer_a.map_to_host() as h_buffer_a:
            fill_buffer(h_buffer_a)

        with buffer_b.map_to_host() as h_buffer_b:
            fill_buffer(h_buffer_b)

        matrix_a = MatrixA(buffer_a)
        matrix_b = MatrixB(buffer_b)
        matrix_c = MatrixC(buffer_c)

        ctx.enqueue_function[
            matmul_thread_per_output_cell[layout_a, layout_b, layout_c]
        ](
            matrix_a,
            matrix_b,
            matrix_c,
            grid_dim=BLOCKS,
            block_dim=THREADS,
        )

        ctx.synchronize()

        with buffer_a.map_to_host() as h_buffer_a:
            with buffer_b.map_to_host() as h_buffer_b:
                with buffer_c.map_to_host() as h_buffer_c:
                    assert_allclose(
                        (ROWS_A, COLS_A, h_buffer_a),
                        (ROWS_B, COLS_B, h_buffer_b),
                        (ROWS_C, COLS_C, h_buffer_c),
                    )

    except e:
        print("Prininting here: ", e)


fn assert_allclose(
    buff_a_with_dims: (Int, Int, HostBuffer[dtype]),
    buff_b_with_dims: (Int, Int, HostBuffer[dtype]),
    buff_c_with_dims: (Int, Int, HostBuffer[dtype]),
) raises:
    a_rows, a_cols, a_buff = buff_a_with_dims
    matrix_a = reshape(to_ndarray(a_buff), a_rows, a_cols)

    b_rows, b_cols, b_buff = buff_b_with_dims
    matrix_b = reshape(to_ndarray(b_buff), b_rows, b_cols)

    c_rows, c_cols, c_buff = buff_c_with_dims
    matrix_c = reshape(to_ndarray(c_buff), c_rows, c_cols)
    np = Python.import_module("numpy")
    assert_true(np.allclose(np.matmul(matrix_a, matrix_b), matrix_c))
    print("Assertion was successful")


fn to_ndarray(buffer: HostBuffer[dtype]) raises -> PythonObject:
    np = Python.import_module("numpy")
    ndarray = np.zeros(len(buffer), dtype=np.float32)
    ndarray_ptr = ndarray_ptr[dtype](ndarray)
    buffer_ptr = buffer.unsafe_ptr()
    memcpy(ndarray_ptr, buffer_ptr, len(buffer))
    return ndarray


fn reshape(ndarray: PythonObject, rows: Int, cols: Int) raises -> PythonObject:
    return ndarray.reshape(rows, cols)


fn ndarray_ptr[
    dtype: DType
](ndarray: PythonObject) raises -> UnsafePointer[Scalar[dtype]]:
    return ndarray.__array_interface__["data"][0].unsafe_get_as_pointer[dtype]()

