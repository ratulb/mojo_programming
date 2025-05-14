### Add 10
### Implement a kernel that adds 10 to each position of vector a and stores it in vector out.

from gpu.host import DeviceContext
from memory import UnsafePointer
from gpu import thread_idx

alias SIZE = 4
alias BLOCKS_PER_GRID = 1
alias THREADS_PER_BLOCK = SIZE
alias dtype = DType.float32


fn add_10(
    out: UnsafePointer[Scalar[dtype]], array: UnsafePointer[Scalar[dtype]]
):
    tid = thread_idx.x
    out[tid] = array[tid] + 10


fn main() raises:
    ctx = DeviceContext()
    d_array_buff = ctx.enqueue_create_buffer[dtype](SIZE)
    expected = ctx.enqueue_create_buffer[dtype](SIZE)
    d_out_buff = ctx.enqueue_create_buffer[dtype](SIZE)

    _ = d_out_buff.enqueue_fill(0)

    with d_array_buff.map_to_host() as h_array_buff:
        for i in range(SIZE):
            h_array_buff[i] = i

    ctx.enqueue_function[add_10](
        d_out_buff.unsafe_ptr(),
        d_array_buff.unsafe_ptr(),
        grid_dim=BLOCKS_PER_GRID,
        block_dim=THREADS_PER_BLOCK,
    )

    ctx.synchronize()

    with d_out_buff.map_to_host() as h_out_buff:
        print(h_out_buff)

