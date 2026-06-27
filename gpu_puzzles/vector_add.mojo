### Add vectors
### Mojo kernel that adds vectors with grid strides, simd and loop unrolling

from std.gpu.host import DeviceContext, HostBuffer, DeviceAttribute
from std.gpu import thread_idx, block_idx, block_dim, grid_dim
from std.testing import assert_almost_equal
from utils import Timer
from std.random import random_float64, seed
from std.sys import has_accelerator, simd_width_of


def vector_add[
    dtype: DType,
    simd_width: Int = simd_width_of[dtype](),
    simd_vectors_per_thread: Int = 2 * simd_width,
](
    result: UnsafePointer[Scalar[dtype], MutAnyOrigin],
    a: UnsafePointer[Scalar[dtype], ImmutAnyOrigin],
    b: UnsafePointer[Scalar[dtype], ImmutAnyOrigin],
    size: Int,
):
    var tid = block_idx.x * block_dim.x + thread_idx.x
    var grid_stride = grid_dim.x * block_dim.x

    comptime CHUNK_SIZE = simd_vectors_per_thread * simd_width
    # =========================================================
    # Each thread processes CHUNK_SIZE elements
    # =========================================================
    var start_index = (
        tid * CHUNK_SIZE
    )  # Start index for each thread per grid_stride

    while start_index < size:
        comptime for vector in range(simd_vectors_per_thread):
            var i = start_index + vector * simd_width

            # Bound check for this vector
            if i + simd_width <= size:
                # Load whole vectors, add up and store
                result.store[width=simd_width](
                    i, a.load[width=simd_width](i) + b.load[width=simd_width](i)
                )
            else:  # i < size, can not load a simd_length vector, handle tail
                for j in range(i, size):
                    result.store[width=1](
                        j, a.load[width=1](j) + b.load[width=1](j)
                    )

        start_index += grid_stride * CHUNK_SIZE


def vector_add_cpu[
    dtype: DType,
    //,
](
    result: HostBuffer[dtype],
    a: HostBuffer[dtype],
    b: HostBuffer[dtype],
    size: Int,
):
    var i = 0
    while i < size:
        result[i] = a[i] + b[i]
        i += 1


def fill[
    dtype: DType,
    //,
](
    buffer_a: HostBuffer[dtype],
    init_seed: Optional[Int] = None,
    min: Float64 = 1.0,
    max: Float64 = 10.0,
):
    if init_seed:
        seed(init_seed.value())
    else:
        seed()
    for i in range(len(buffer_a)):
        buffer_a[i] = random_float64(min, max).cast[dtype]()


def main() raises:
    comptime dtype = DType.float32
    var size = 100000000
    var cpu_ctx = DeviceContext(api="cpu")

    var lhs_host_buffer = cpu_ctx.enqueue_create_host_buffer[dtype](size)
    var rhs_host_buffer = cpu_ctx.enqueue_create_host_buffer[dtype](size)
    var result_host_buffer = cpu_ctx.enqueue_create_host_buffer[dtype](size)

    fill(lhs_host_buffer, init_seed=42)
    fill(rhs_host_buffer, init_seed=123)
    with Timer("CPU execution took: "):
        vector_add_cpu(
            result_host_buffer, lhs_host_buffer, rhs_host_buffer, size
        )
    cpu_ctx.synchronize()

    comptime if has_accelerator():
        var gpu_ctx = DeviceContext()

        var result_gpu_buffer = gpu_ctx.enqueue_create_buffer[dtype](size)
        var lhs_gpu_buffer = gpu_ctx.enqueue_create_buffer[dtype](size)
        var rhs_gpu_buffer = gpu_ctx.enqueue_create_buffer[dtype](size)

        lhs_host_buffer.enqueue_copy_to(dst=lhs_gpu_buffer)
        rhs_host_buffer.enqueue_copy_to(dst=rhs_gpu_buffer)

        var max_blocks = gpu_ctx.get_attribute(
            DeviceAttribute.MAX_BLOCKS_PER_MULTIPROCESSOR
        )
        var sm_count = gpu_ctx.get_attribute(
            DeviceAttribute.MULTIPROCESSOR_COUNT
        )
        var threads_per_block = 256
        var blocks_count = max_blocks * sm_count * 32
        print("Max block per sm: ", max_blocks, "sm count: ", sm_count)
        print(
            "Launching",
            blocks_count,
            "blocks with",
            threads_per_block,
            "threads per block",
        )

        with Timer("GPU execution took: "):
            gpu_ctx.enqueue_function[vector_add[dtype]](
                result_gpu_buffer.unsafe_ptr(),
                lhs_gpu_buffer.unsafe_ptr(),
                rhs_gpu_buffer.unsafe_ptr(),
                size,
                grid_dim=blocks_count,
                block_dim=threads_per_block,
            )
            gpu_ctx.synchronize()

        with result_gpu_buffer.map_to_host() as gpu_result:
            for i in range(size):
                assert_almost_equal(gpu_result[i], result_host_buffer[i])
