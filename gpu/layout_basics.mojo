from gpu.host import DeviceContext
from layout import Layout, LayoutTensor

comptime HEIGHT = 2
comptime WIDTH = 3
comptime dtype = DType.float32
comptime layout = Layout.row_major(HEIGHT, WIDTH)
comptime BLOCKS_PER_GRID = 1
comptime THREADS_PER_BLOCK = 1


def kernel[
    dtype: DType, layout: Layout
](tensor: LayoutTensor[mut=True, dtype, layout]):
    print("Before\n")
    print(tensor)
    tensor[0, 0] += 1.0
    print()
    print("After\n")
    print(tensor)


def main():
    ctx = DeviceContext(api="cuda")
    cpu_ctx = DeviceContext(api="cpu")
    buffer = ctx.enqueue_create_buffer[dtype](HEIGHT * WIDTH).enqueue_fill(0)
    cpu_buffer = cpu_ctx.enqueue_create_host_buffer[dtype](HEIGHT * WIDTH)

    for i in range(HEIGHT * WIDTH):
        cpu_buffer[i] = i**2

    cpu_buffer.enqueue_copy_to(buffer)

    tensor = LayoutTensor[mut=True, dtype, layout](buffer.unsafe_ptr())

    ctx.enqueue_function[kernel[dtype, layout]](
        tensor, grid_dim=BLOCKS_PER_GRID, block_dim=THREADS_PER_BLOCK
    )

    ctx.synchronize()

    print(ctx.name())
    print(ctx.api())
    print(cpu_ctx.api())
    cpu_buffer.unsafe_ptr()[] = 98.0
    print(cpu_buffer)

