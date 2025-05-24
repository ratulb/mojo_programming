### Add constant to 2D Layout tensor
### Implement a kernel that adds 10 to each position of 2D LayoutTensor a and stores it in 2D LayoutTensor out.

from gpu.host import DeviceContext
from gpu import thread_idx
from layout import Layout, LayoutTensor
from math import iota


alias SIZE = 2
alias BLOCKS_PER_GRID = 1
alias THREADS_PER_BLOCK = (3, 3)
alias dtype = DType.float32
alias layout = Layout.row_major(SIZE, SIZE)


fn add_10_2dlayout(
    out: LayoutTensor[mut=True, dtype, layout],
    a: LayoutTensor[mut=True, dtype, layout],
    size: Int,
):
    row = thread_idx.y
    col = thread_idx.x
    # FILL ME IN (roughly 2 lines)
    if row < size and col < size:
        out[row, col] = a[row, col] + 10


fn main():
    try:
        ctx = DeviceContext()

        buffer_a = ctx.enqueue_create_buffer[dtype](SIZE * SIZE).enqueue_fill(
            0.0
        )
        buffer_out = ctx.enqueue_create_buffer[dtype](SIZE * SIZE).enqueue_fill(
            0.0
        )

        with buffer_a.map_to_host() as h_buffer_a:
            iota(h_buffer_a.unsafe_ptr(), SIZE * SIZE)

        out = LayoutTensor[mut=True, dtype, layout](buffer_out)
        a = LayoutTensor[mut=True, dtype, layout](buffer_a)

        ctx.enqueue_function[add_10_2dlayout](
            out,
            a,
            SIZE,
            grid_dim=(BLOCKS_PER_GRID, BLOCKS_PER_GRID),
            block_dim=THREADS_PER_BLOCK,
        )

        ctx.synchronize()

        with buffer_out.map_to_host() as h_buffer_out:
            print(h_buffer_out)
    except e:
        print(e)

