
### Add vectors
### Mojo kernel for adding corresponding elements of vectors a and b, store in out.

from gpu.host import DeviceContext
from memory import UnsafePointer
from gpu import thread_idx, block_idx, block_dim
from testing import assert_equal

alias SIZE = 4
alias BLOCKS_PER_GRID = 1
alias THREADS_PER_BLOCK = SIZE
alias dtype = DType.float32


fn add(
    out: UnsafePointer[Scalar[dtype]],
    a: UnsafePointer[Scalar[dtype]],
    b: UnsafePointer[Scalar[dtype]],
):
    tid = block_idx.x * block_dim.x + thread_idx.x
    if tid < SIZE:
        out[tid] = a[tid] + b[tid]


fn main() raises:
    ctx = DeviceContext()
    d_array_buff_1 = ctx.enqueue_create_buffer[dtype](SIZE)
    d_array_buff_2 = ctx.enqueue_create_buffer[dtype](SIZE)
    d_out_buff = ctx.enqueue_create_buffer[dtype](SIZE)
    expected = ctx.enqueue_create_host_buffer[dtype](SIZE)
    _ = d_out_buff.enqueue_fill(0)
    _ = expected.enqueue_fill(SIZE - 1)

    with d_array_buff_1.map_to_host() as h_array_buff_1:
        for i in range(SIZE):
            h_array_buff_1[i] = i

    with d_array_buff_2.map_to_host() as h_array_buff_2:
        for i in range(SIZE - 1, -1, -1):
            h_array_buff_2[SIZE - 1 - i] = i

    ctx.enqueue_function[add](
        d_out_buff.unsafe_ptr(),
        d_array_buff_1.unsafe_ptr(),
        d_array_buff_2.unsafe_ptr(),
        grid_dim=BLOCKS_PER_GRID,
        block_dim=THREADS_PER_BLOCK,
    )

    ctx.synchronize()

    with d_out_buff.map_to_host() as h_out_buff:
        print(h_out_buff)
        for i in range(SIZE):
            assert_equal(h_out_buff[i], expected[i])

