from std.gpu.host import DeviceContext
from std.sys import has_accelerator
from layout import Layout, LayoutTensor

comptime HEIGHT = 2
comptime WIDTH = 3
comptime dtype = DType.float32
comptime layout = Layout.row_major(HEIGHT, WIDTH)
comptime BLOCKS_PER_GRID = 1
comptime THREADS_PER_BLOCK = 1


def kernel[
    dtype: DType, layout: Layout
](data: UnsafePointer[Scalar[dtype], MutAnyOrigin]):
    var tensor = LayoutTensor[mut=True, dtype, layout, _](data)
    print("Before\n")
    print(tensor)
    tensor[0, 0] += 1.0
    print()
    print("After\n")
    print(tensor)


def main() raises:
    var host_buffer = DeviceContext(api="cpu").enqueue_create_host_buffer[
        dtype
    ](HEIGHT * WIDTH)

    for i in range(HEIGHT * WIDTH):
        host_buffer[i] = Float32(i**2)

    comptime if has_accelerator():
        var ctx = DeviceContext()
        var device_buffer = ctx.enqueue_create_buffer[dtype](HEIGHT * WIDTH)
        device_buffer.enqueue_fill(0)
        host_buffer.enqueue_copy_to(device_buffer)
        ctx.enqueue_function[kernel[dtype, layout]](
            device_buffer.unsafe_ptr(),
            grid_dim=BLOCKS_PER_GRID,
            block_dim=THREADS_PER_BLOCK,
        )
        ctx.synchronize()
    else:
        var cpu_buffer = DeviceContext(api="cpu").enqueue_create_buffer[dtype](
            HEIGHT * WIDTH
        )
        cpu_buffer.enqueue_fill(0)
        host_buffer.enqueue_copy_to(cpu_buffer)
        kernel[dtype, layout](cpu_buffer.unsafe_ptr())

    print(host_buffer)
