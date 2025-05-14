
### Add 10
### Implement a kernel that adds 10 to each position of vector a and stores it in vector out.
### More threads than data — guard against out-of-bounds access.

from gpu.host import DeviceContext
from memory import UnsafePointer
from gpu import thread_idx, block_dim, block_idx
from testing import assert_equal

alias SIZE = 4
alias BLOCKS_PER_GRID = 1
alias THREADS_PER_BLOCK = (8, 1)
alias dtype = DType.float32


fn add_10_with_guard(
    out: UnsafePointer[Scalar[dtype]], array: UnsafePointer[Scalar[dtype]]
):
    tid = (
        thread_idx.z * (block_dim.y * block_dim.x)
        + thread_idx.y * block_dim.x
        + thread_idx.x
    )

    if tid < SIZE:
        out[tid] = array[tid] + 10


fn main() raises:
    ctx = DeviceContext()
    d_array_buff = ctx.enqueue_create_buffer[dtype](SIZE)
    d_out_buff = ctx.enqueue_create_buffer[dtype](SIZE)
    expected = ctx.enqueue_create_host_buffer[dtype](SIZE)
    _ = d_out_buff.enqueue_fill(0)

    with d_array_buff.map_to_host() as h_array_buff:
        for i in range(SIZE):
            h_array_buff[i] = i

    ctx.enqueue_function[add_10_with_guard](
        d_out_buff.unsafe_ptr(),
        d_array_buff.unsafe_ptr(),
        grid_dim=BLOCKS_PER_GRID,
        block_dim=THREADS_PER_BLOCK,
    )

    ctx.synchronize()

    for i in range(SIZE):
        expected[i] = i + 10

    print(expected)

    with d_out_buff.map_to_host() as h_out_buff:
        print(h_out_buff)
        for i in range(SIZE):
            assert_equal(h_out_buff[i], expected[i])

