### Add vectors
### Mojo kernel for adding corresponding elements of vectors a and b, store in result.

from std.gpu.host import DeviceContext, HostBuffer, DeviceAttribute
from std.gpu import thread_idx, block_idx, block_dim, grid_dim
from std.testing import assert_almost_equal
from utils import Timer
from std.random import random_float64, seed
from std.sys import has_accelerator


def vector_add[
    dtype: DType,
](
    result: UnsafePointer[Scalar[dtype], MutAnyOrigin],
    a: UnsafePointer[Scalar[dtype], ImmutAnyOrigin],
    b: UnsafePointer[Scalar[dtype], ImmutAnyOrigin],
    size: Int,
):
    var tid = block_idx.x * block_dim.x + thread_idx.x
    var stride = grid_dim.x * block_dim.x
    while tid < size:
        result[tid] = a[tid] + b[tid]
        tid += stride


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
    var size = 1000000
    var cpu_ctx = DeviceContext(api="cpu")

    var lhs_host_buffer = cpu_ctx.enqueue_create_host_buffer[dtype](size)
    var rhs_host_buffer = cpu_ctx.enqueue_create_host_buffer[dtype](size)
    var result_host_buffer = cpu_ctx.enqueue_create_host_buffer[dtype](size)

    fill(lhs_host_buffer, init_seed=42)
    fill(rhs_host_buffer, init_seed=123)
    with Timer("CPU addition took: "):
        vector_add_cpu(
            result_host_buffer, lhs_host_buffer, rhs_host_buffer, size
        )
    # Post cpu addition make a copy of buff_c_h
    cpu_ctx.synchronize()
    print(result_host_buffer)

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
        with Timer("GPU execution took: "):
            gpu_ctx.enqueue_function[vector_add[dtype]](
                result_gpu_buffer.unsafe_ptr(),
                lhs_gpu_buffer.unsafe_ptr(),
                rhs_gpu_buffer.unsafe_ptr(),
                size,
                grid_dim=max_blocks,
                block_dim=256,
            )
            gpu_ctx.synchronize()

        with result_gpu_buffer.map_to_host() as gpu_result:
            for i in range(size):
                assert_almost_equal(gpu_result[i], result_host_buffer[i])
