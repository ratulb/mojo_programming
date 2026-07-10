"""
Vectorized Memory Access & SIMD Grid-Stride Add.

Most GPU kernels are bandwidth bound: the bottleneck is moving bytes between global
memory and the ALUs, not the arithmetic itself.  A scalar load/store instruction
(`LDG.E` / `STG.E` in CUDA) moves 32 bits per operation.  Modern GPUs also support
wider instructions — `LDG.E.64`, `LDG.E.128` — that transfer 64 or 128 bits in a
single op, cutting instruction count by 2-4× and improving throughput.

The NVIDIA blog post [CUDA Pro Tip: Increase Performance with Vectorized Memory
Access](https://developer.nvidia.com/blog/cuda-pro-tip-write-flexible-kernels-grid-stride-loops/) lays out the basic technique in CUDA C++: cast an `int*` to `int2*` or
`int4*` and the compiler generates the wider loads.  A scalar copy loop that
processes one element per thread becomes 2× (int2) or 4× (int4) fewer instructions,
directly raising bandwidth utilisation.  The key requirement is alignment — device
memory is naturally aligned to the vector width.

This Mojo kernel goes one step further.

━━━ What this kernel does ━━━

  • Uses Mojo's native SIMD intrinsics (`load[width=N]` / `store[width=N]`) for
    vectorised memory access.  The SIMD width is auto-detected from the data type
    (`simd_width_of[dtype]()`), so the code adapts to float32 (width 4), float64
    (width 2), etc.

  • Each thread processes `simd_vectors_per_thread × simd_width` elements per grid
    step — a compile-time unrolled block of SIMD vectors.  The blog post stops at
    one vectorised element per thread per iteration; here a single thread moves
    16 float32 values at once (e.g. 4 vectors × width 4).

  • A grid-stride outer loop makes the kernel grid-size-agnostic: each thread
    strides across the array by `grid_dim × block_dim`, so the same kernel works
    whether you launch 16 blocks or 1600.

  • A scalar tail loop handles leftover elements that don't fill a full SIMD
    vector, without warping the fast path.

  • Runs on both CPU (`DeviceContext(api="cpu")`) and GPU (when an accelerator
    is available), comparing results with `assert_almost_equal`.

  • A companion CUDA implementation lives in `gpu/vector_add.cu`, showing the
    same ideas — float4 vectorised loads and `#pragma unroll` — in native CUDA C++.

━━━ Data-flow diagram ━━━

    Global memory:  [ e0 │ e1 │ e2 │ e3 │ e4 │ e5 │ e6 │ e7 │ ... │ eN ]
                            │
              ┌─────────────┴──────────────────┐
              │  Grid-stride loop (outer)      │
              │  thread t starts at            │
              │  t × CHUNK_SIZE and advances   │
              │  by grid_dim × block_dim chunks│
              └─────────────┬──────────────────┘
                            │
              ┌─────────────┴─────────────────────────┐
              │  CHUNK_SIZE per iteration             │
              │  ┌──── simd_vectors_per_thread ────┐  │
              │  │  vector 0 │ vector 1 │ ...      │  │
              │  │ ┌──────┐  ┌──────┐  ┌──────┐    │  │
              │  │ │ SIMD │  │ SIMD │  │ SIMD │    │  │
              │  │ │ WWWW │  │ WWWW │  │ WWWW │    │  │
              │  │ └──────┘  └──────┘  └──────┘    │  │
              │  └─────────────────────────────────┘  │
              │  Each SIMD block = simd_width elements│
              │  loaded/stored as one unit            │
              └─────────────┬─────────────────────────┘
                            │
              ┌─────────────┴──────────────────┐
              │  Wide load / store:            │
              │  a.load[width=4](i)            │
              │  → LDG.E.128 (4 × float32)     │
              │                                │
              │  result.store[width=4](i, ...) │
              │  → STG.E.128 (4 × float32)     │
              └────────────────────────────────┘

━━━ Running ━━━

    pixi run mojo -I . gpu/vector_add.mojo

The kernel fills two random vectors (or uses a seed for reproducibility), adds
them on CPU for reference, then on GPU (if one is available), and asserts
element-wise equality within a tolerance.
"""

from std.gpu.host import DeviceContext, HostBuffer, DeviceAttribute
from std.gpu import thread_idx, block_idx, block_dim, grid_dim
from std.testing import assert_almost_equal
from utils import Timer
from std.random import random_float64, seed
from std.sys import has_accelerator, simd_width_of


# GPU kernel: element-wise vector addition with grid-stride loop, SIMD loads,
# and compile-time loop unrolling. Each thread processes CHUNK_SIZE elements
# per iteration, then advances by the total grid stride.
#
# Parameters:
#   result: output pointer (mutably addressed)
#   a, b: input pointers (immutably addressed)
#   size: number of elements in each vector
#
# Template parameters:
#   dtype: element data type (e.g. DType.float32)
#   simd_width: SIMD width, auto-detected from dtype
#   simd_vectors_per_thread: number of SIMD vectors per thread per grid step
#
def vector_add[
    dtype: DType,
    simd_width: Int = simd_width_of[dtype](),
    simd_vectors_per_thread: Int = 4 * simd_width,
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


# CPU reference implementation: simple sequential element-wise vector addition.
#
# Parameters:
#   result: output host buffer
#   a, b: input host buffers
#   size: number of elements
#
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


# Fill a host buffer with random float64 values cast to the target dtype.
# Optionally accepts a seed for reproducible results.
#
# Parameters:
#   buffer_a: host buffer to fill
#   init_seed: optional RNG seed (deterministic if provided)
#   min, max: range for random values
#
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


# Benchmark vector addition on CPU and (if available) GPU, then validate that
# all GPU results match the CPU reference within a small tolerance.
#
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

        var max_blocks_per_sm = gpu_ctx.get_attribute(
            DeviceAttribute.MAX_BLOCKS_PER_MULTIPROCESSOR
        )
        var sm_count = gpu_ctx.get_attribute(
            DeviceAttribute.MULTIPROCESSOR_COUNT
        )
        var threads_per_block = 256
        var max_threads_per_sm = gpu_ctx.get_attribute(
           DeviceAttribute.MAX_THREADS_PER_MULTIPROCESSOR
        )
        var max_blocks = max_threads_per_sm // threads_per_block
        var blocks_count = min(max_blocks_per_sm, max_blocks) * sm_count * 4
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
