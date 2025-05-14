### Add a constant 10
### Implement a kernel that adds 10 to each position of 2d matrix a and stores it in out 2d matrix.


from gpu.host import DeviceContext
from memory import UnsafePointer
from gpu import thread_idx, block_dim
from testing import assert_equal

alias SIZE = 2
alias BLOCKS_PER_GRID = 1
alias THREADS_PER_BLOCK = (3,3)
alias dtype = DType.float32


fn add_10_2d(
    out: UnsafePointer[Scalar[dtype]], array: UnsafePointer[Scalar[dtype]], size: Int
):
    tid = thread_idx.z * (block_dim.y * block_dim.x) + thread_idx.y * block_dim.x + thread_idx.x
    if tid < size * size:
        out[tid] = array[tid] + 10


fn main():
  try:
    ctx = DeviceContext()
    d_array_buff = ctx.enqueue_create_buffer[dtype](SIZE * SIZE).enqueue_fill(0)
    d_out_buff = ctx.enqueue_create_buffer[dtype](SIZE * SIZE).enqueue_fill(0)
    expected = ctx.enqueue_create_host_buffer[dtype](SIZE * SIZE).enqueue_fill(0)


    with d_array_buff.map_to_host() as h_array_buff:
        for i in range(SIZE):
            for j in range(SIZE):
                h_array_buff[i * SIZE + j] = i * SIZE + j
                expected[i * SIZE + j] = h_array_buff[i * SIZE + j] + 10
        print("Input: ", h_array_buff)

    ctx.enqueue_function[add_10_2d](
            d_out_buff.unsafe_ptr(),
            d_array_buff.unsafe_ptr(),
            SIZE,
            grid_dim=BLOCKS_PER_GRID,
            block_dim=THREADS_PER_BLOCK,
        )

    ctx.synchronize()

    with d_out_buff.map_to_host() as h_out_buff:
        print(h_out_buff)
        print(expected)
        for i in range(SIZE * SIZE ):
            assert_equal(h_out_buff[i], expected[i])

  except e:
    print(e) 
